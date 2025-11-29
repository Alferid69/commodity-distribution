"use client";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { subHours } from "date-fns";
import { ChevronDown } from "lucide-react";
import { useTranslation } from "react-i18next";

interface TransactionTableProps {
  userRole: string | null;
  filteredData: any[];
  groupedTransactions: { [key: string]: any };
  shopsGroupedByCooperative: {
    [key: string]: { cooperative: any; shops: any[] };
  };
  currentCooperativeShops: any[];
  isLoading: boolean;
  shopsLoading: boolean;
  cooperativesLoading: boolean;
  isAnyFilterApplied: boolean;
  handleShopClick: (shopId: string) => void;
}

export default function TransactionTable({
  userRole,
  filteredData,
  groupedTransactions,
  shopsGroupedByCooperative,
  currentCooperativeShops,
  isLoading,
  shopsLoading,
  cooperativesLoading,
  isAnyFilterApplied,
  handleShopClick,
}: TransactionTableProps) {
  const { t } = useTranslation();

  if (userRole === "RetailerCooperativeShop") {
    return (
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>{t("name")}</TableHead>
            <TableHead>{t("date")}</TableHead>
            <TableHead>{t("commodity")}</TableHead>
            <TableHead>{t("quantity")}</TableHead>
            <TableHead>{t("status")}</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {filteredData.length > 0 ? (
            filteredData.map((transaction: any) => (
              <TableRow key={transaction._id}>
                <TableCell className="font-medium">
                  {transaction.customerId?.name}
                </TableCell>
                <TableCell>
                  {subHours(new Date(transaction.createdAt), 6).toLocaleString(
                    "en-US",
                    {
                      year: "numeric",
                      month: "2-digit",
                      day: "2-digit",
                      hour: "2-digit",
                      minute: "2-digit",
                      second: "2-digit",
                      hour12: true,
                    }
                  )}
                </TableCell>
                <TableCell>{transaction.commodity?.name || "-"}</TableCell>
                <TableCell>{transaction.amount}</TableCell>
                <TableCell>
                  <span
                    className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${
                      transaction.status === "success"
                        ? "bg-green-100 text-green-800"
                        : transaction.status === "pending"
                        ? "bg-yellow-100 text-yellow-800"
                        : "bg-red-100 text-red-800"
                    }`}
                  >
                    {t(transaction.status)}
                  </span>
                </TableCell>
              </TableRow>
            ))
          ) : (
            <TableRow>
              <TableCell colSpan={6} className="h-24 text-center">
                {isLoading
                  ? t("Loading transactions...")
                  : isAnyFilterApplied
                  ? t(
                      "No transactions found matching your applied filters. Please adjust your criteria."
                    )
                  : t("No transactions found for this shop.")}
              </TableCell>
            </TableRow>
          )}
        </TableBody>
      </Table>
    );
  }

  if (
    [
      "TradeBureau",
      "SubCityOffice",
      "WoredaOffice",
      "RetailerCooperative",
    ].includes(userRole || "")
  ) {
    return (
      <Table>
        <TableHeader>
          <TableRow>
            {userRole === "RetailerCooperative" ? (
              <>
                <TableHead>{t("shopName")}</TableHead>
                <TableHead>{t("totalTransactions")}</TableHead>
                <TableHead>{t("actions")}</TableHead>
              </>
            ) : (
              <>
                <TableHead>{t("cooperative")}</TableHead>
                <TableHead>{t("totalTransactions")}</TableHead>
                <TableHead>{t("totalShops")}</TableHead>
                <TableHead>{t("actions")}</TableHead>
              </>
            )}
          </TableRow>
        </TableHeader>
        <TableBody>
          {userRole === "RetailerCooperative" ? (
            currentCooperativeShops.length > 0 ? (
              currentCooperativeShops.map((shop: any) => {
                const shopTransactions = filteredData.filter(
                  (transaction: any) => transaction.shopId?._id === shop._id
                ).length;

                return (
                  <TableRow key={shop._id}>
                    <TableCell>{shop.name}</TableCell>
                    <TableCell>{shopTransactions}</TableCell>
                    <TableCell>
                      <Button
                        variant="ghost"
                        size="icon"
                        onClick={() => handleShopClick(shop._id)}
                      >
                        <span className="sr-only">{t("View Shop")}</span>
                        <ChevronDown className="h-4 w-4" />{" "}
                      </Button>
                    </TableCell>
                  </TableRow>
                );
              })
            ) : (
              <TableRow>
                <TableCell colSpan={3} className="h-24 text-center">
                  {isLoading || shopsLoading
                    ? t("Loading shops...")
                    : isAnyFilterApplied
                    ? t(
                        "No shops found matching your applied filters. Please adjust your criteria."
                      )
                    : t("No shops found for this cooperative.")}
                </TableCell>
              </TableRow>
            )
          ) : Object.entries(shopsGroupedByCooperative).length > 0 ? (
            Object.entries(shopsGroupedByCooperative).map(
              ([cooperativeId, data]: [string, any]) => {
                const totalTransactionsCoop =
                  groupedTransactions[cooperativeId]?.transactions?.length || 0;
                return (
                  <TableRow key={cooperativeId}>
                    <TableCell>{data.cooperative.name}</TableCell>
                    <TableCell>{totalTransactionsCoop}</TableCell>
                    <TableCell>{data.shops.length}</TableCell>
                    <TableCell>
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button variant="ghost" className="h-8 w-8 p-0">
                            <span className="sr-only">Open menu</span>
                            <ChevronDown className="h-4 w-4" />
                          </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                          {data.shops.map((shop: any) => (
                            <DropdownMenuItem
                              key={shop._id}
                              onClick={() => handleShopClick(shop._id)}
                            >
                              {t("View Shop")} {shop.name}
                            </DropdownMenuItem>
                          ))}
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </TableCell>
                  </TableRow>
                );
              }
            )
          ) : (
            <TableRow>
              <TableCell colSpan={4} className="h-24 text-center">
                {isLoading || cooperativesLoading
                  ? t("Loading cooperatives...")
                  : isAnyFilterApplied
                  ? t(
                      "No cooperatives found matching your applied filters. Please adjust your criteria."
                    )
                  : t("No cooperatives found.")}
              </TableCell>
            </TableRow>
          )}
        </TableBody>
      </Table>
    );
  }

  return null;
}
