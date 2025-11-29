"use client";

import { getCommodities } from "@/app/api/apiCommodities";
import { getCustomerFayda } from "@/app/api/apiCustomers";
import { getRetailerCooperativeShopById } from "@/app/api/apiRetailerCooperativeShops";
import { createTransaction } from "@/app/api/apiTransactions";
import { getCurrentUser } from "@/app/api/auth/auth";
import { decodeJWT } from "@/app/api/auth/decode";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { useQuery } from "@tanstack/react-query";
import { useEffect, useState } from "react";
import { useTranslation } from "react-i18next";
import { toast } from "react-toastify";
import QrScannerComponent from "../QRScanner";

export default function TransactionCreateForm({
  onSuccess,
}: {
  onSuccess?: () => void;
}) {
  const { t } = useTranslation();
  const [userRole, setUserRole] = useState<string | null>(null);
  const [customerId, setCustomerId] = useState("");
  const [faydaNumber, setFaydaNumber] = useState(""); // New state for fayda number
  const [name, setName] = useState("");
  const [houseNumber, setHouseNumber] = useState("");
  const [woreda, setWoreda] = useState("");
  const [commodity, setCommodity] = useState("");
  const [amount, setAmount] = useState("5");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [showScanner, setShowScanner] = useState(true);
  const [scanningError, setScanningError] = useState<string | null>(null);
  const [scanningLoading, setScanningLoading] = useState(false);

  useEffect(() => {
    const role = decodeJWT(localStorage.getItem("token") || "")?.role.name;
    setUserRole(role);
  }, []);

  // Fetch commodities using useQuery
  const {
    data: commoditiesData,
    isLoading: commoditiesLoading,
    error: commoditiesError,
  } = useQuery({
    queryKey: ["commodities"],
    queryFn: () => getCommodities(localStorage.getItem("token") || ""),
  });

  const { data: userDataResult, isLoading: userLoading } = useQuery({
    queryKey: ["user"],
    queryFn: () => getCurrentUser(localStorage.getItem("token") || ""),
  });

  const { data: retailerCooperativeData, isLoading: isLoadingCoop } = useQuery({
    queryKey: ["cooperatives"],
    queryFn: () =>
      getRetailerCooperativeShopById(
        localStorage.getItem("token") || "",
        userDataResult?.data.worksAt
      ),
  });

  const handleScanFayda = async (fayda: string) => {
    setScanningLoading(true);
    setScanningError(null);
    try {
      const token = localStorage.getItem("token") || "";
      const res = await getCustomerFayda(token, fayda);
      if (res && res.data) {
        setCustomerId(res.data.customer._id || "");
        setFaydaNumber(fayda); // Save the scanned fayda number
        setName(res.data.customer.name || "");
        setHouseNumber(res.data.customer.house_no || "");
        setWoreda(res.data.customer.woreda.name || "");
        setShowScanner(false);
      } else {
        toast.error("Customer not found with scanned Fayda number.");
      }
    } catch (error) {
      console.log(error);
      setScanningError("Error fetching customer data by Fayda number.");
      toast.error("Error fetching customer data by Fayda number.");
    } finally {
      setScanningLoading(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    if (!commodity || !amount) {
      setError("Please fill all required fields.");
      return;
    }

    setLoading(true);
    try {
      const payload = {
        shopId: userDataResult?.data?.worksAt,
        customerId,
        commodity,
        amount: Number(amount),
        fayda: faydaNumber,
      };

      const res = await createTransaction(
        localStorage.getItem("token") || "",
        payload
      );
      if (res.status !== "success") {
        toast.error(t("transactionFailed"));
        setLoading(false);
      } else {
        toast.success(t("transactionSuccess"));
        if (onSuccess) onSuccess();
      }
    } catch (err) {
      setError(err?.response?.data?.message || "Transaction failed");
      toast.error(t("transactionFailed"));
    } finally {
      setLoading(false);
    }
  };

  return (
    <>
      {showScanner && (
        <div className="fixed inset-0 z-50 bg-black bg-opacity-75 flex flex-col items-center justify-center p-4">
          <div className="w-full max-w-md bg-white rounded-lg p-4 relative">
            <button
              onClick={() => setShowScanner(false)}
              className="absolute top-2 right-2 text-gray-600 hover:text-gray-900"
              aria-label="Close Scanner"
            >
              ✕
            </button>
            <QrScannerComponent
              onScanSuccess={(fayda: string) => handleScanFayda(fayda)}
              onError={(err: string) => setScanningError(err)}
            />
            {scanningLoading && <p className="mt-2 text-center">Loading customer data...</p>}
            {scanningError && <p className="mt-2 text-center text-red-500">{scanningError}</p>}
          </div>
        </div>
      )}
      <form onSubmit={handleSubmit} className="space-y-4 max-w-md mx-auto">
        {/* Non-editable fields */}
        <div>
          <Label htmlFor="name">{t("name")}</Label>
          <Input id="name" value={name} readOnly placeholder="Name" />
        </div>
        <div>
          <Label htmlFor="houseNumber">{t("houseNumber")}</Label>
          <Input
            id="houseNumber"
            value={houseNumber}
            readOnly
            placeholder="House Number"
          />
        </div>
        <div>
          <Label htmlFor="woreda">{t("woreda")}</Label>
          <Input id="woreda" value={woreda} readOnly placeholder="Woreda" />
        </div>
        {/* Commodity */}
        <div>
          <Label htmlFor="commodity">{t("commodity")}</Label>
          <Select
            value={commodity}
            onValueChange={setCommodity}
            disabled={commoditiesLoading || !!commoditiesError}
          >
            <SelectTrigger id="commodity">
              <SelectValue placeholder={t("selectCommodity")} />
            </SelectTrigger>
            <SelectContent>
              {retailerCooperativeData &&
                retailerCooperativeData.data.availableCommodity.map(
                  (item: any) => (
                    <SelectItem key={item._id} value={item.commodity._id}>
                      {item.commodity.name}{" "}
                      {item.commodity.price
                        ? `- ${item.commodity.price} birr`
                        : ""}
                    </SelectItem>
                  )
                )}
            </SelectContent>
          </Select>
        </div>
        <div>
          <Label htmlFor="amount">{t("quantity")}</Label>
          <Input
            id="amount"
            type="number"
            min={1}
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            placeholder={t("enterQuantity")}
          />
        </div>
        {error && <div className="text-red-500 text-sm">{error}</div>}
        <Button type="submit" disabled={loading}>
          {loading ? t("loading") : t("Create Transaction")}
        </Button>
      </form>
    </>
  );
}
