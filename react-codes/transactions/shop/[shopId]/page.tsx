"use client";
import { getRetailerCooperativeShopById } from "@/app/api/apiRetailerCooperativeShops";
import { getTransactionsByShopId } from "@/app/api/apiTransactions";
import { decodeJWT } from "@/app/api/auth/decode";
import { Button } from "@/components/ui/button";
import { Calendar } from "@/components/ui/calendar";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import Loader from "@/components/ui/loader";
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { useQuery } from "@tanstack/react-query";
import { format, subHours } from "date-fns";
import { CalendarIcon, Download, Search, XCircle } from "lucide-react"; // Added CalendarIcon
import { useParams } from "next/navigation";
import { useEffect, useMemo, useState } from "react";
import { useTranslation } from "react-i18next";
import { toast } from "react-toastify";
import * as XLSX from "xlsx-js-style";

export default function ShopTransactionsPage() {
  const { t } = useTranslation();
  const params = useParams();
  const shopId = params.shopId as string;
  const [userRole, setUserRole] = useState("");
  const [searchText, setSearchText] = useState("");
  const [selectedCommodity, setSelectedCommodity] = useState("all");
  const [selectedStatus, setSelectedStatus] = useState("all");
  const [startDate, setStartDate] = useState<Date | undefined>(undefined);
  const [endDate, setEndDate] = useState<Date | undefined>(undefined);
  const [appliedStartDate, setAppliedStartDate] = useState<Date | undefined>(
    undefined
  );
  const [appliedEndDate, setAppliedEndDate] = useState<Date | undefined>(
    undefined
  );

  useEffect(() => {
    const decoded = decodeJWT(localStorage.getItem("token") || "");
    if (decoded) {
      setUserRole(decoded.role.name);
    }
  }, []);

  const { isLoading, data } = useQuery({
    queryKey: ["shopTransactions", shopId, appliedStartDate, appliedEndDate],
    queryFn: () =>
      getTransactionsByShopId(
        localStorage.getItem("token"),
        shopId,
        appliedStartDate,
        appliedEndDate
      ),
    enabled: !!shopId,
  });

  const { data: shopData, isLoading: isLoadingShop } = useQuery({
    queryKey: ["shop", shopId],
    queryFn: () =>
      getRetailerCooperativeShopById(localStorage.getItem("token"), shopId),
    enabled: !!shopId,
  });

  const handleSearchDates = () => {
    setAppliedStartDate(startDate);
    setAppliedEndDate(endDate);
  };

  const handleClearDates = () => {
    setStartDate(undefined);
    setEndDate(undefined);
    setAppliedStartDate(undefined);
    setAppliedEndDate(undefined);
  };

  const handleResetFilters = () => {
    setSearchText("");
    setSelectedCommodity("all");
    setSelectedStatus("all");
    setStartDate(undefined);
    setEndDate(undefined);
    setAppliedStartDate(undefined);
    setAppliedEndDate(undefined);
  };

  const filteredData = useMemo(() => {
    if (!data?.data) return [];

    return data.data
      .filter((transaction: any) => {
        const matchesSearch = transaction.customerId?.name
          ?.toLowerCase()
          .includes(searchText.toLowerCase());
        const matchesCommodity =
          selectedCommodity === "all" ||
          transaction.commodity?.name?.toLowerCase() === selectedCommodity;
        const matchesStatus =
          selectedStatus === "all" ||
          transaction.status?.toLowerCase() === selectedStatus;

        return matchesSearch && matchesCommodity && matchesStatus;
      })
      .sort((a: any, b: any) => {
        return (
          new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
        );
      });
  }, [searchText, selectedCommodity, selectedStatus, data]);

  // Calculate summary metrics
  const totalTransactions = filteredData.length;
  const totalQuantitySold = filteredData.reduce(
    (sum: number, transaction: any) => sum + (transaction.amount || 0),
    0
  );
  const totalRevenue = filteredData.reduce((sum: number, transaction: any) => {
    const quantity = transaction.amount || 0;
    const pricePerUnit = transaction.commodity?.price || 0;
    return sum + quantity * pricePerUnit;
  }, 0);

  if (isLoading || isLoadingShop) return <Loader />;

  const exportToExcel = () => {
    if (!filteredData || filteredData.length === 0) {
      toast.info("No data available to export");
      return;
    }

    const worksheetData: any[][] = [];

    // Date Range Title Logic (unchanged from your provided code)
    let dateRangeTitle = "ሁሉም ግብይቶች"; // All Transactions
    if (appliedStartDate && appliedEndDate) {
      dateRangeTitle = `ግብይቶች ከ ${format(
        appliedStartDate,
        "dd-MM-yyyy"
      )} እስከ ${format(appliedEndDate, "dd-MM-yyyy")}`;
    } else if (appliedStartDate) {
      dateRangeTitle = `ግብይቶች ከ ${format(appliedStartDate, "dd-MM-yyyy")} ጀምሮ`;
    } else if (appliedEndDate) {
      dateRangeTitle = `ግብይቶች እስከ ${format(appliedEndDate, "dd-MM-yyyy")}`;
    } else {
      const today = new Date();
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(today.getDate() - 30);
      dateRangeTitle = `ግብይቶች ከ ${format(
        thirtyDaysAgo,
        "dd-MM-yyyy"
      )} እስከ ${format(today, "dd-MM-yyyy")} (ባለፉት 30 ቀናት)`;
    }

    worksheetData.push([dateRangeTitle]);
    worksheetData.push([]); // Empty row for spacing

    const calculateTotalPrice = (transaction: any) => {
      const quantity = transaction.amount || 0;
      const pricePerUnit = transaction.commodity?.price || 0;
      return quantity * pricePerUnit;
    };

    const headers = [
      "ተ.ቁ", // Index 0: Serial Number
      "ቀን", // Index 1: Date
      "እቃ", // Index 2: Commodity
      "መጠን", // Index 3: Amount (Quantity)
      "የአንዱ ዋጋ", // Index 4: Price Per Unit
      "አጠቃላይ ዋጋ", // Index 5: Total Price
      "ሱቅ", // Index 6: Shop
      "ደንበኛ", // Index 7: Customer
    ];

    let overallTotalQuantity = 0;
    let overallTotalPrice = 0;

    const transactionsByCommodity: { [key: string]: any[] } = {};
    filteredData.forEach((transaction: any) => {
      const commodityName = transaction.commodity?.name || "Unknown";
      if (!transactionsByCommodity[commodityName]) {
        transactionsByCommodity[commodityName] = [];
      }
      transactionsByCommodity[commodityName].push(transaction);
    });

    // --- Define Styles (Simplified as per "lightweight" request) ---
    const titleStyle = {
      font: { bold: true, sz: 16, name: "Nyala" },
      alignment: { horizontal: "center" },
    };
    const boldFontNyala = { font: { bold: true, name: "Nyala" } };
    const normalFontNyala = { font: { name: "Nyala" } }; // Default font for data cells

    // Your original headerStyle, renamed for consistency with my internal variable
    const headerStyle = {
      font: { bold: true, sz: 11, color: { rgb: "FFFFFFFF" }, name: "Nyala" },
      fill: { fgColor: { rgb: "FF4F81BD" } },
      alignment: { horizontal: "center", vertical: "center", wrapText: true },
      // Keeping basic borders as per your original code structure
      border: {
        top: { style: "thin", color: { rgb: "FFBBBBBB" } },
        bottom: { style: "thin", color: { rgb: "FFBBBBBB" } },
        left: { style: "thin", color: { rgb: "FFBBBBBB" } },
        right: { style: "thin", color: { rgb: "FFBBBBBB" } },
      },
    };

    const commodityHeaderStyle = {
      font: { bold: true, sz: 14, color: { rgb: "FF000000" }, name: "Nyala" },
      fill: { fgColor: { rgb: "FFDDDDDD" } },
      alignment: { horizontal: "left", vertical: "center" },
      border: { bottom: { style: "medium", color: { rgb: "FF999999" } } },
    };

    const subtotalStyle = {
      font: { bold: true, sz: 11, color: { rgb: "FF000000" }, name: "Nyala" },
      fill: { fgColor: { rgb: "FFF2F2F2" } },
      alignment: { horizontal: "right", vertical: "center" },
      border: {
        top: { style: "medium", color: { rgb: "FFCCCCCC" } },
        bottom: { style: "medium", color: { rgb: "FFCCCCCC" } },
      },
    };

    const overallTotalStyle = {
      font: { bold: true, sz: 13, color: { rgb: "FFFFFFFF" }, name: "Nyala" },
      fill: { fgColor: { rgb: "FF6B8E23" } },
      alignment: { horizontal: "right", vertical: "center" },
      border: {
        top: { style: "thick", color: { rgb: "FF000000" } },
        bottom: { style: "thick", color: { rgb: "FF000000" } },
      },
    };

    const dataCellStyle = {
      // Keeping this as per your last input, it does include borders
      font: { sz: 10, color: { rgb: "FF333333" }, name: "Nyala" },
      alignment: { horizontal: "left", vertical: "top" },
      border: {
        top: { style: "thin", color: { rgb: "FFDDDDDD" } },
        bottom: { style: "thin", color: { rgb: "FFDDDDDD" } },
        left: { style: "thin", color: { rgb: "FFDDDDDD" } },
        right: { style: "thin", color: { rgb: "FFDDDDDD" } },
      },
    };

    // --- Track Row Indices ---
    const dateRangeTitleRowIndex = 0;
    const commodityHeaderRows: number[] = [];
    const mainHeadersRows: number[] = [];
    const subtotalRows: number[] = [];
    let overallTotalRowIndex = -1; // Use this variable consistently

    let currentRow = 0;
    currentRow += 2; // Account for initial title and empty row

    for (const commodityName in transactionsByCommodity) {
      if (
        Object.prototype.hasOwnProperty.call(
          transactionsByCommodity,
          commodityName
        )
      ) {
        // Commodity section header
        worksheetData.push([
          `እቃ: ${commodityName === "sugar" ? "ስኳር" : "ዘይት"}`,
        ]);
        commodityHeaderRows.push(currentRow);
        currentRow++;

        // Main headers for this commodity group
        worksheetData.push(headers);
        mainHeadersRows.push(currentRow);
        currentRow++;

        let commodityTotalQuantity = 0;
        let commodityTotalPrice = 0;

        transactionsByCommodity[commodityName].forEach(
          (transaction: any, index: number) => {
            const totalPrice = calculateTotalPrice(transaction);
            commodityTotalQuantity += transaction.amount || 0;
            commodityTotalPrice += totalPrice;
            overallTotalQuantity += transaction.amount || 0;
            overallTotalPrice += totalPrice;

            worksheetData.push([
              index + 1 + "", // Serial Number (Number)
              format(
                subHours(new Date(transaction.createdAt), 6),
                "dd-MM-yyyy hh:mm:ss a"
              ),
              commodityName === "sugar" ? "ስኳር" : "ዘይት", // Commodity name (Amharic)
              transaction.amount, // Quantity (Number)
              transaction.commodity?.price || 0, // Price Per Unit (Number)
              totalPrice, // Total Price (Number)
              transaction.shopId?.name || "-",
              transaction.customerId?.name || "-",
            ]);
            currentRow++;
          }
        );

        worksheetData.push([]); // Empty row for spacing
        currentRow++;

        // Commodity Subtotal row
        worksheetData.push([
          "",
          "",
          "ድምር", // "ድምር" aligns under 'እቃ' (Index 2)
          commodityTotalQuantity, // Quantity (Number)
          "", // Empty for 'የአንዱ ዋጋ'
          commodityTotalPrice, // Total Price (Number)
          "",
          "", // Empty for 'ሱቅ', 'ደንበኛ'
        ]);
        subtotalRows.push(currentRow);
        currentRow++;

        worksheetData.push([]); // Empty row for spacing between commodity groups
        currentRow++;
      }
    }

    // Overall Total row
    worksheetData.push([
      "",
      "",
      "",
      "", // Empty for 'የአንዱ ዋጋ'
      "ጠቅላላ ድምር", // "ጠቅላላ ድምር" aligns under 'እቃ' (Index 2)
      overallTotalPrice, // Total Price (Number)
      "",
      "", // Empty for 'ሱቅ', 'ደንበኛ'
    ]);
    overallTotalRowIndex = currentRow; // Correctly use overallTotalRowIndex here

    const ws = XLSX.utils.aoa_to_sheet(worksheetData);

    // --- Apply Styles and Formats to the Worksheet ---
    const fullRange = XLSX.utils.decode_range(ws["!ref"] || "A1");
    const numberOfColumns = headers.length;

    // Apply title style and merge
    const titleCellAddress = XLSX.utils.encode_cell({
      r: dateRangeTitleRowIndex,
      c: 0,
    });
    if (ws[titleCellAddress]) {
      ws[titleCellAddress].s = titleStyle;
      const mergeRange = XLSX.utils.encode_range({
        s: { r: dateRangeTitleRowIndex, c: 0 },
        e: { r: dateRangeTitleRowIndex, c: numberOfColumns - 1 },
      });
      if (!ws["!merges"]) ws["!merges"] = [];
      ws["!merges"].push(XLSX.utils.decode_range(mergeRange));
    }

    // Apply commodity header style and merge
    commodityHeaderRows.forEach((rowIndex) => {
      const cellAddress = XLSX.utils.encode_cell({ r: rowIndex, c: 0 });
      if (!ws[cellAddress]) ws[cellAddress] = {};
      ws[cellAddress].s = commodityHeaderStyle;
      const mergeRange = XLSX.utils.encode_range({
        s: { r: rowIndex, c: 0 },
        e: { r: rowIndex, c: numberOfColumns - 1 },
      });
      if (!ws["!merges"]) ws["!merges"] = [];
      ws["!merges"].push(XLSX.utils.decode_range(mergeRange));
    });

    // Apply main header style
    mainHeadersRows.forEach((rowIndex) => {
      for (let C = 0; C < numberOfColumns; ++C) {
        const cellAddress = XLSX.utils.encode_cell({ r: rowIndex, c: C });
        if (!ws[cellAddress]) ws[cellAddress] = {};
        ws[cellAddress].s = headerStyle;
      }
    });

    // Apply subtotal row styles and number formats
    subtotalRows.forEach((rowIndex) => {
      for (let C = 0; C < numberOfColumns; ++C) {
        const cellAddress = XLSX.utils.encode_cell({ r: rowIndex, c: C });
        if (!ws[cellAddress]) ws[cellAddress] = {};
        ws[cellAddress].s = subtotalStyle;
      }
      // Align "ድምር" text left
      if (ws[XLSX.utils.encode_cell({ r: rowIndex, c: 2 })]) {
        // "ድምር" is in column C (index 2)
        ws[XLSX.utils.encode_cell({ r: rowIndex, c: 2 })].s.alignment = {
          horizontal: "left",
        };
      }

      // Apply quantity format
      if (ws[XLSX.utils.encode_cell({ r: rowIndex, c: 3 })]) {
        // Quantity (መጠን) column (index 3)
        let groupCommodityName = "Unknown";
        const relevantCommodityHeaderRow = commodityHeaderRows.find(
          (chRow) => chRow < rowIndex && chRow + 1 < rowIndex
        );
        if (relevantCommodityHeaderRow !== undefined) {
          const commodityHeaderCell =
            ws[XLSX.utils.encode_cell({ r: relevantCommodityHeaderRow, c: 0 })];
          if (
            commodityHeaderCell &&
            typeof commodityHeaderCell.v === "string"
          ) {
            groupCommodityName = commodityHeaderCell.v.split(": ")[1];
          }
        }
        if (groupCommodityName === "ስኳር") {
          ws[XLSX.utils.encode_cell({ r: rowIndex, c: 3 })].z = '0 "ኪ.ግ"';
        } else if (groupCommodityName === "ዘይት") {
          ws[XLSX.utils.encode_cell({ r: rowIndex, c: 3 })].z = '0 "ሊትር"';
        } else {
          ws[XLSX.utils.encode_cell({ r: rowIndex, c: 3 })].z = "0";
        }
      }
      // Apply total price format
      if (ws[XLSX.utils.encode_cell({ r: rowIndex, c: 5 })]) {
        // Total Price (አጠቃላይ ዋጋ) column (index 5)
        ws[XLSX.utils.encode_cell({ r: rowIndex, c: 5 })].z = '0.00 "ብር"';
      }
    });

    // Apply overall total row styles and number formats
    if (overallTotalRowIndex !== -1) {
      for (let C = 0; C < numberOfColumns; ++C) {
        const cellAddress = XLSX.utils.encode_cell({
          r: overallTotalRowIndex,
          c: C,
        });
        if (!ws[cellAddress]) ws[cellAddress] = {};
        ws[cellAddress].s = overallTotalStyle;
        ws[cellAddress].s.sz = 13; // Slightly larger for overall total
      }
      // Align "ጠቅላላ ድምር" text left
      if (ws[XLSX.utils.encode_cell({ r: overallTotalRowIndex, c: 2 })]) {
        // "ጠቅላላ ድምር" is in column C (index 2)
        ws[
          XLSX.utils.encode_cell({ r: overallTotalRowIndex, c: 2 })
        ].s.alignment = { horizontal: "left" };
      }
      // Apply quantity format
      if (ws[XLSX.utils.encode_cell({ r: overallTotalRowIndex, c: 3 })]) {
        // Quantity (index 3)
        ws[XLSX.utils.encode_cell({ r: overallTotalRowIndex, c: 3 })].z = "0";
      }
      // Apply total price format
      if (ws[XLSX.utils.encode_cell({ r: overallTotalRowIndex, c: 5 })]) {
        // Total Price (index 5)
        ws[XLSX.utils.encode_cell({ r: overallTotalRowIndex, c: 5 })].z =
          '0.00 "ብር"';
      }
    }

    // Apply data cell styles and specific number formats
    const firstDataRow =
      mainHeadersRows.length > 0 ? mainHeadersRows[0] + 1 : 2;
    const lastDataRow = overallTotalRowIndex - 1;

    for (let R = fullRange.s.r; R <= fullRange.e.r; ++R) {
      if (
        R === dateRangeTitleRowIndex ||
        commodityHeaderRows.includes(R) ||
        mainHeadersRows.includes(R) ||
        subtotalRows.includes(R) ||
        R === overallTotalRowIndex ||
        worksheetData[R]?.length === 0
      ) {
        continue;
      }

      for (let C = 0; C < numberOfColumns; ++C) {
        const cellAddress = XLSX.utils.encode_cell({ r: R, c: C });
        if (!ws[cellAddress]) ws[cellAddress] = {};
        ws[cellAddress].s = dataCellStyle; // Apply basic data cell style

        // Apply specific number formats based on column index
        if (C === 1) {
          // Date (ቀን) column (index 1)
          ws[cellAddress].z = "dd-MM-yyyy hh:mm:ss AM/PM";
        } else if (C === 3) {
          // Amount (መጠን) column (index 3)
          const currentCommodity = worksheetData[R]?.[2]; // Commodity name from current row (index 2)
          let unit = "";
          if (typeof currentCommodity === "string") {
            if (currentCommodity === "ስኳር") unit = "ኪ.ግ";
            else if (currentCommodity === "ዘይት") unit = "ሊትር";
          }
          ws[cellAddress].z = `0 "${unit}"`;
        } else if (C === 4) {
          // Price Per Unit (የአንዱ ዋጋ) column (index 4)
          ws[cellAddress].z = '0.00 "ብር"';
        } else if (C === 5) {
          // Total Price (አጠቃላይ ዋጋ) column (index 5)
          ws[cellAddress].z = '0.00 "ብር"';
        }
      }
    }

    // Auto-fit columns with specific width for the first column
    const colWidths: { wch: number }[] = [];
    headers.forEach((header, i) => {
      let wch = 10; // Default reasonable width for general columns

      if (i === 0) {
        // "ተ.ቁ" (Serial Number)
        wch = 5; // Fixed small width for serial number
      } else if (i === 1) {
        // "ቀን" (Date)
        wch = 20;
      } else if (i === 2) {
        // "እቃ" (Commodity)
        wch = 12;
      } else if (i === 3) {
        // "መጠን" (Amount)
        wch = 12;
      } else if (i === 4) {
        // "የአንዱ ዋጋ" (Price Per Unit)
        wch = 15;
      } else if (i === 5) {
        // "አጠቃላይ ዋጋ" (Total Price)
        wch = 15;
      } else if (i === 6) {
        // "ሱቅ" (Shop)
        wch = 15;
      } else if (i === 7) {
        // "ደንበኛ" (Customer)
        wch = 20;
      }
      colWidths.push({ wch: wch });
    });
    ws["!cols"] = colWidths;

    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, "የግብይት ሪፖርት"); // Sheet name in Amharic

    const now = new Date();
    const formattedDate = format(now, "yyyy-MM-dd_HH-mm-ss");
    const fileName = `${
      shopData?.data?.name ? shopData.data.name + "_" : ""
    }የግብይት_ሪፖርት_${formattedDate}.xlsx`;

    XLSX.writeFile(wb, fileName);
  };

  const isAnyFilterApplied =
    searchText !== "" ||
    selectedCommodity !== "all" ||
    selectedStatus !== "all" ||
    startDate !== undefined ||
    endDate !== undefined;

  return (
    <div className="flex flex-col gap-4">
      <div className="w-full sm:flex-row sm:items-center sm:justify-between">
        <h2 className="text-3xl text-center font-bold tracking-tight">
          {t("transactions")} - {shopData?.data?.name}
        </h2>

        <div className="mt-4 grid grid-cols-1 md:grid-cols-3 gap-4">
          <Card className="text-center">
            <CardHeader>
              <CardTitle className="text-lg">
                {t("Total Transactions")}
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-2xl font-bold">{totalTransactions}</p>
            </CardContent>
          </Card>
          <Card className="text-center">
            <CardHeader>
              <CardTitle className="text-lg">
                {t("Total Quantity Sold")}
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-2xl font-bold">
                {totalQuantitySold.toFixed(2)} {t("units")}
              </p>
            </CardContent>
          </Card>
          <Card className="text-center">
            <CardHeader>
              <CardTitle className="text-lg">{t("Total Revenue")}</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-2xl font-bold">
                {totalRevenue.toFixed(2)} {t("currency")}
              </p>
            </CardContent>
          </Card>
        </div>

        <div className="mt-4 flex flex-col sm:flex-row items-center justify-between gap-2">
          <div className="flex gap-2">
            <Button variant="outline" size="sm" onClick={() => exportToExcel()}>
              <Download className="mr-2 h-4 w-4" />
              {t("export")}
            </Button>
            {/* <Button
            variant="outline"
            size="sm"
            onClick={() => exportToPDF(filteredData, shopData)}
            >
            <Download className="mr-2 h-4 w-4" />
            {t("exportP")}
          </Button> */}
          </div>
          <div className="flex flex-wrap items-center gap-2">
            <Popover>
              <PopoverTrigger asChild>
                <Button
                  variant={"outline"}
                  className="text-start font-normal sm:w-36"
                >
                  <CalendarIcon className="mr-2 h-4 w-4" />
                  {startDate ? format(startDate, "PPP") : t("Start Date")}
                </Button>
              </PopoverTrigger>
              <PopoverContent className="w-auto p-0" align="start">
                <Calendar
                  mode="single"
                  selected={startDate}
                  onSelect={setStartDate}
                  initialFocus
                />
              </PopoverContent>
            </Popover>
            <Popover>
              <PopoverTrigger asChild>
                <Button
                  variant={"outline"}
                  className="text-start font-normal sm:w-36"
                >
                  <CalendarIcon className="mr-2 h-4 w-4" />
                  {endDate ? format(endDate, "PPP") : t("End Date")}
                </Button>
              </PopoverTrigger>
              <PopoverContent className="w-auto p-0" align="start">
                <Calendar
                  mode="single"
                  selected={endDate}
                  onSelect={setEndDate}
                  initialFocus
                />
              </PopoverContent>
            </Popover>
            <Button
              size="sm"
              onClick={handleSearchDates}
              disabled={!startDate && !endDate}
            >
              <Search className="mr-2 h-4 w-4" />
              {t("Search")}
            </Button>
            {isAnyFilterApplied && (
              <Button variant="outline" size="sm" onClick={handleResetFilters}>
                <XCircle className="mr-2 h-4 w-4" />
                {t("Reset Filters")}
              </Button>
            )}
          </div>
        </div>

        {/* Date Range Feedback */}
        <div className="mt-2 text-sm text-muted-foreground text-right pr-2">
          {appliedStartDate || appliedEndDate
            ? `${t("Showing data from")} ${
                appliedStartDate
                  ? format(appliedStartDate, "PPP")
                  : t("the beginning")
              } ${t("To")} ${
                appliedEndDate ? format(appliedEndDate, "PPP") : t("now")
              }`
            : t("Showing all dates")}
        </div>
      </div>

      <div className="flex flex-col gap-4 sm:flex-row sm:items-center">
        <div className="flex flex-1 items-center space-x-2">
          <div className="relative flex-1">
            <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
            <Input
              type="search"
              placeholder={`${t("searchTransactions")} by customer name`}
              className="w-full pl-8"
              value={searchText}
              onChange={(e) => setSearchText(e.target.value)}
            />
          </div>
        </div>
        <div className="grid grid-cols-2 gap-2 sm:flex">
          <div>
            <Label htmlFor="commodity" className="sr-only">
              {t("commodity")}
            </Label>
            <Select
              value={selectedCommodity}
              onValueChange={setSelectedCommodity}
            >
              <SelectTrigger id="commodity" className="w-full sm:w-[150px]">
                <SelectValue placeholder={t("commodity")} />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">{t("allCommodities")}</SelectItem>
                <SelectItem value="sugar">{t("sugar")}</SelectItem>
                <SelectItem value="oil">{t("oil")}</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </div>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>{t("transactions")}</CardTitle>
          <CardDescription>{t("viewAllTransactions")}</CardDescription>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>{t("name")}</TableHead>
                <TableHead>{t("date")}</TableHead>
                <TableHead>{t("commodity")}</TableHead>
                <TableHead>{t("quantity")}</TableHead>
                <TableHead>{t("seller")}</TableHead>
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
                      {subHours(
                        new Date(transaction.createdAt),
                        6
                      ).toLocaleString("en-US", {
                        year: "numeric",
                        month: "2-digit",
                        day: "2-digit",
                        hour: "2-digit",
                        minute: "2-digit",
                        second: "2-digit",
                        hour12: true,
                      })}
                    </TableCell>
                    <TableCell>{transaction.commodity?.name || "-"}</TableCell>
                    <TableCell>{transaction.amount}</TableCell>
                    <TableCell>{transaction.user?.name || "-"}</TableCell>
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
        </CardContent>
      </Card>
    </div>
  );
}
