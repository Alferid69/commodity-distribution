"use client";
import { getRetailerCooperatives } from "@/app/api/apiRetailerCooperatives";
import {
  getRetailerCooperativeShopById,
  getRetailerCooperativeShops,
} from "@/app/api/apiRetailerCooperativeShops";
import { getTransactions } from "@/app/api/apiTransactions";
import { getWoredas } from "@/app/api/apiWoreda";
import { getCurrentUser } from "@/app/api/auth/auth";
import { decodeJWT } from "@/app/api/auth/decode";
import TransactionCreateModal from "@/components/transaction/TransactionCreateModal";
import TransactionFilters from "@/components/transaction/TransactionFilters";
import TransactionSummaryCards from "@/components/transaction/TransactionSummaryCards";
import TransactionTable from "@/components/transaction/TransactionTable";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import Loader from "@/components/ui/loader";
import { useQuery } from "@tanstack/react-query";
import { format, subHours } from "date-fns";
import { useRouter } from "next/navigation";
import { useEffect, useMemo, useState } from "react";
import { useTranslation } from "react-i18next";
import { toast } from "react-toastify";

import * as XLSX from "xlsx-js-style";

export default function TransactionsPage() {
  const { t } = useTranslation();
  const router = useRouter();

  const [userRole, setUserRole] = useState<string | null>(null);
  const [showCreateForm, setShowCreateForm] = useState(false);
  const [searchText, setSearchText] = useState("");
  const [selectedCommodity, setSelectedCommodity] = useState("all");
  const [selectedStatus, setSelectedStatus] = useState("all");
  const [selectedCooperative, setSelectedCooperative] = useState("all");
  const [selectedShop, setSelectedShop] = useState("all");
  const [selectedWoreda, setSelectedWoreda] = useState("all");
  const [startDate, setStartDate] = useState<Date | undefined>(undefined);
  const [endDate, setEndDate] = useState<Date | undefined>(undefined);
  const [appliedStartDate, setAppliedStartDate] = useState<Date | undefined>(
    undefined
  );
  const [appliedEndDate, setAppliedEndDate] = useState<Date | undefined>(
    undefined
  );

  const ROLES_WITH_NEW_FEATURES = useMemo(
    () => ["RetailerCooperative", "RetailerCooperativeShop"],
    []
  );

  useEffect(() => {
    const decoded = decodeJWT(localStorage.getItem("token") || "");
    if (decoded) {
      setUserRole(decoded.role.name);
    }
  }, []);

  const exportToExcel = () => {
    if (!filteredData || filteredData.length === 0) {
      toast.info("No data available to export");
      return;
    }

    const worksheetData: any[][] = [];

    // Date Range Title Logic
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

    // Add the date range title to the top of the worksheet
    worksheetData.push([dateRangeTitle]);
    worksheetData.push([]); // Empty row for spacing

    const calculateTotalPrice = (transaction: any) => {
      const quantity = transaction.amount || 0;
      const pricePerUnit = transaction.commodity?.price || 0;
      return quantity * pricePerUnit;
    };

    const headers = [
      "ተ.ቁ", // Serial Number
      "ቀን", // Date
      "እቃ", // Commodity
      "መጠን", // Amount (Quantity)
      "የአንዱ ዋጋ", // Price Per Unit
      "አጠቃላይ ዋጋ", // Total Price
      "ሱቅ", // Shop
      "ደንበኛ", // Customer
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

    // --- Define Lightweight Styles ---
    const titleStyle = {
      font: { bold: true, sz: 16, name: "Nyala" },
      alignment: { horizontal: "center" },
    };

    const boldFontNyala = { font: { bold: true, name: "Nyala" } };
    const normalFontNyala = { font: { name: "Nyala" } };

    // Keep track of special row indices for styling later
    const dateRangeTitleRowIndex = 0;
    const commodityHeaderRows: number[] = [];
    const mainHeadersRows: number[] = [];
    const subtotalRows: number[] = [];
    let overallTotalRowIndex: number = -1;

    let currentRow = 0; // Current row index in worksheetData

    // Account for initial dateRangeTitle and empty row for `currentRow` tracking
    currentRow += 2;

    for (const commodityName in transactionsByCommodity) {
      if (
        Object.prototype.hasOwnProperty.call(
          transactionsByCommodity,
          commodityName
        )
      ) {
        worksheetData.push([
          `እቃ: ${commodityName === "sugar" ? "ስኳር" : "ዘይት"}`,
        ]); // Commodity section header in Amharic
        commodityHeaderRows.push(currentRow);
        currentRow++;

        worksheetData.push(headers); // Headers for this commodity section
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
              index + 1 + "",
              format(
                subHours(new Date(transaction.createdAt), 6),
                "dd-MM-yyyy hh:mm:ss a"
              ), // Adjusted for Ethiopian-style time
              commodityName === "sugar" ? "ስኳር" : "ዘይት",
              transaction.amount,
              transaction.commodity?.price || 0,
              totalPrice,
              transaction.shopId?.name || "-",
              transaction.customerId?.name || "-",
            ]);
            currentRow++;
          }
        );

        worksheetData.push([]); // Empty row for spacing
        currentRow++;

        worksheetData.push([
          "", // For "ተ.ቁ"
          "", // For "ቀን"
          "ድምር",
          `${commodityTotalQuantity} ${
              commodityName === "sugar" ? "ኪ.ግ" : "ሊትር"
            }`,
          "", // For "የአንዱ ዋጋ"
          `${commodityTotalPrice} ብር`, // Number (now at index 5)
          "", // For "ሱቅ"
          "", // For "ደንበኛ"
        ]);
        subtotalRows.push(currentRow);
        currentRow++;

        worksheetData.push([]); // Empty row for spacing between commodity groups
        currentRow++;
      }
    }

    // // Add overall total
    // worksheetData.push([
    //   "ጠቅላላ ድምር", // Overall Total in Amharic (now at index 0)
    //   "", // For "ቀን"
    //   "", // For "እቃ"
    //   overallTotalQuantity, // Number (now at index 3)
    //   "", // For "የአንዱ ዋጋ"
    //   overallTotalPrice, // Number (now at index 5)
    //   "", // For "ሱቅ"
    //   "", // For "ደንበኛ"
    // ]);
    overallTotalRowIndex = currentRow;

    const ws = XLSX.utils.aoa_to_sheet(worksheetData);

    // --- Apply Lightweight Styles to the Worksheet ---
    const sheetRange = XLSX.utils.decode_range(ws["!ref"] || "A1");

    // Date Range Title Style (A1)
    const titleCellAddress = XLSX.utils.encode_cell({
      r: dateRangeTitleRowIndex,
      c: 0,
    });
    if (ws[titleCellAddress]) {
      ws[titleCellAddress].s = titleStyle;
      const mergeRange = XLSX.utils.encode_range({
        s: { r: dateRangeTitleRowIndex, c: 0 },
        e: { r: dateRangeTitleRowIndex, c: headers.length - 1 },
      });
      if (!ws["!merges"]) ws["!merges"] = [];
      ws["!merges"].push(XLSX.utils.decode_range(mergeRange));
    }

    // Apply bold to commodity headers and merge
    commodityHeaderRows.forEach((rowIndex) => {
      const cellAddress = XLSX.utils.encode_cell({ r: rowIndex, c: 0 });
      if (!ws[cellAddress]) ws[cellAddress] = {};
      ws[cellAddress].s = boldFontNyala;
      ws[cellAddress].s.sz = 14; // Slightly larger for commodity headers
      ws[cellAddress].s.alignment = { horizontal: "left", vertical: "center" };
      const mergeRange = XLSX.utils.encode_range({
        s: { r: rowIndex, c: 0 },
        e: { r: rowIndex, c: headers.length - 1 },
      });
      if (!ws["!merges"]) ws["!merges"] = [];
      ws["!merges"].push(XLSX.utils.decode_range(mergeRange));
    });

    // Apply bold to main headers
    mainHeadersRows.forEach((rowIndex) => {
      for (let C = sheetRange.s.c; C < headers.length; ++C) {
        const cellAddress = XLSX.utils.encode_cell({ r: rowIndex, c: C });
        if (!ws[cellAddress]) ws[cellAddress] = {};
        ws[cellAddress].s = boldFontNyala;
        ws[cellAddress].s.alignment = { horizontal: "center", wrapText: true };
      }
    });

    // Apply bold and number formats to subtotals
    subtotalRows.forEach((rowIndex) => {
      for (let C = 0; C < headers.length; ++C) {
        const cellAddress = XLSX.utils.encode_cell({ r: rowIndex, c: C });
        if (!ws[cellAddress]) ws[cellAddress] = {};
        ws[cellAddress].s = boldFontNyala;
      }
      // Specific alignment for "ድምር" text
      if (ws[XLSX.utils.encode_cell({ r: rowIndex, c: 1 })]) {
        // "ድምር" text is in column B (index 1)
        ws[XLSX.utils.encode_cell({ r: rowIndex, c: 1 })].s.alignment = {
          horizontal: "left",
          vertical: "center",
        };
      }
      // Apply number format to quantity and total price in subtotal row
      if (ws[XLSX.utils.encode_cell({ r: rowIndex, c: 3 })]) {
        // Quantity (መጠን) column (index 3)
        // Get commodity name from its group header (2 rows above the subtotal row)
        let groupCommodityName = "Unknown";
        // Find the commodity header row that precedes this subtotal row
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
          // Sugar is 'ኪ.ግ'
          ws[XLSX.utils.encode_cell({ r: rowIndex, c: 3 })].z = '0 "ኪ.ግ"';
        } else if (groupCommodityName === "ዘይት") {
          // Oil is 'ሊትር'
          ws[XLSX.utils.encode_cell({ r: rowIndex, c: 3 })].z = '0 "ሊትር"';
        } else {
          ws[XLSX.utils.encode_cell({ r: rowIndex, c: 3 })].z = "0";
        }
      }
      if (ws[XLSX.utils.encode_cell({ r: rowIndex, c: 5 })]) {
        // Total Price (አጠቃላይ ዋጋ) column (index 5)
        ws[XLSX.utils.encode_cell({ r: rowIndex, c: 5 })].z = '0.00 "ብር"';
      }
    });

    // Apply bold and number formats to overall total
    if (overallTotalRowIndex !== -1) {
      for (let C = 0; C < headers.length; ++C) {
        const cellAddress = XLSX.utils.encode_cell({
          r: overallTotalRowIndex,
          c: C,
        });
        if (!ws[cellAddress]) ws[cellAddress] = {};
        ws[cellAddress].s = boldFontNyala;
        ws[cellAddress].s.sz = 13; // Slightly larger for overall total
      }
      // Specific alignment for "ጠቅላላ ድምር" text
      if (ws[XLSX.utils.encode_cell({ r: overallTotalRowIndex, c: 0 })]) {
        ws[
          XLSX.utils.encode_cell({ r: overallTotalRowIndex, c: 0 })
        ].s.alignment = { horizontal: "left", vertical: "center" };
      }
      if (ws[XLSX.utils.encode_cell({ r: overallTotalRowIndex, c: 3 })]) {
        // Quantity column (index 3)
        ws[XLSX.utils.encode_cell({ r: overallTotalRowIndex, c: 3 })].z = "0";
      }
      if (ws[XLSX.utils.encode_cell({ r: overallTotalRowIndex, c: 5 })]) {
        // Total Price column (index 5)
        ws[XLSX.utils.encode_cell({ r: overallTotalRowIndex, c: 5 })].z =
          '0.00 "ብር"';
      }
    }

    // Apply default font and number formats to data cells
    const firstDataRow =
      mainHeadersRows.length > 0 ? mainHeadersRows[0] + 1 : 2;
    const lastDataRow = overallTotalRowIndex - 1;

    for (let R = firstDataRow; R <= lastDataRow; ++R) {
      if (
        worksheetData[R]?.length === 0 ||
        commodityHeaderRows.includes(R) ||
        mainHeadersRows.includes(R) ||
        subtotalRows.includes(R) ||
        R === overallTotalRowIndex
      ) {
        continue;
      }

      for (let C = sheetRange.s.c; C < headers.length; ++C) {
        const cellAddress = XLSX.utils.encode_cell({ r: R, c: C });
        if (!ws[cellAddress]) ws[cellAddress] = {};
        ws[cellAddress].s = normalFontNyala; // Apply normal font

        // Apply specific number formats based on column index
        if (C === 3) {
          // Amount (Quantity) column (index 3)
          const currentCommodity = worksheetData[R]?.[2]; // Get commodity name (Amharic) from current row
          if (currentCommodity === "ስኳር") {
            // Sugar is 'ኪ.ግ'
            ws[cellAddress].z = '0 "ኪ.ግ"';
          } else if (currentCommodity === "ዘይት") {
            // Oil is 'ሊትር'
            ws[cellAddress].z = '0 "ሊትር"';
          } else {
            ws[cellAddress].z = "0"; // Fallback for other commodities
          }
        } else if (C === 4) {
          // Price Per Unit (index 4)
          ws[cellAddress].z = '0.00 "ብር"';
        } else if (C === 5) {
          // Total Price (index 5)
          ws[cellAddress].z = '0.00 "ብር"';
        } else if (C === 1) {
          // Date (ቀን) column (index 1)
          ws[cellAddress].z = "yyyy-mm-dd hh:mm:ss";
        }
      }
    }

    // Auto-fit columns with specific width for the first column
    const colWidths: { wch: number }[] = [];
    headers.forEach((header, i) => {
      let wch = header.length + 2; // Default width based on header length

      if (i === 0) {
        // First column ("ተ.ቁ")
        wch = 5; // Fixed small width for serial number
      } else {
        // Find max length for each column in data rows
        for (let r = 0; r < worksheetData.length; r++) {
          if (worksheetData[r] && worksheetData[r][i]) {
            const cellValue = String(worksheetData[r][i]);
            wch = Math.max(wch, cellValue.length + 2); // Add padding
          }
        }
      }
      colWidths.push({ wch: wch });
    });
    ws["!cols"] = colWidths;

    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, "የግብይት ሪፖርት"); // Sheet name in Amharic

    const now = new Date();
    const formattedDate = format(now, "yyyy-MM-dd");
    XLSX.writeFile(
      wb,
      `የግብይት_ሪፖርት_${formattedDate}.xlsx` // File name in Amharic
    );
  };

  const { isLoading, data } = useQuery({
    queryKey: ["transactions", appliedStartDate, appliedEndDate],
    queryFn: () => getTransactions(localStorage.getItem("token")),
    enabled: !!userRole,
    refetchInterval: 1000,
  });

  const { data: cooperativesData, isLoading: cooperativesLoading } = useQuery({
    queryKey: ["retailerCooperatives"],
    queryFn: () => getRetailerCooperatives(localStorage.getItem("token")),
    enabled: ["TradeBureau", "SubCityOffice", "WoredaOffice"].includes(
      userRole || ""
    ),
  });

  const { data: shopsData, isLoading: shopsLoading } = useQuery({
    queryKey: ["retailerShops"],
    queryFn: () =>
      getRetailerCooperativeShops(localStorage.getItem("token") || ""),
    enabled: [
      "TradeBureau",
      "SubCityOffice",
      "WoredaOffice",
      "RetailerCooperative",
    ].includes(userRole || ""),
  });

  const { data: userDataResult, isLoading: userLoading } = useQuery({
    queryKey: ["user"],
    queryFn: () => getCurrentUser(localStorage.getItem("token") || ""),
  });

  const { data: currentShopData, isLoading: isLoadingCurrentShop } = useQuery({
    queryKey: ["currentShopAvailableCommodity"],
    queryFn: () =>
      userRole === "RetailerCooperativeShop" &&
      userDataResult?.data?.worksAt &&
      getRetailerCooperativeShopById(
        localStorage.getItem("token") || "",
        userDataResult.data.worksAt
      ),
    enabled:
      userRole === "RetailerCooperativeShop" && !!userDataResult?.data?.worksAt,
    refetchInterval: 1000,
  });

  const { data: woredas, isLoading: isLoadingWoreda } = useQuery({
    queryKey: ["woredas"],
    queryFn: () => getWoredas(localStorage.getItem("token") || ""),
    enabled: userRole === "TradeBureau" || userRole === "SubCityOffice",
  });

  const filteredCooperatives = useMemo(() => {
    if (!cooperativesData?.data) return [];

    let currentCooperatives = cooperativesData.data;

    if (userRole === "WoredaOffice" && userDataResult?.data?.worksAt) {
      currentCooperatives = currentCooperatives.filter((coop: any) => {
        return coop.woredaOffice._id === userDataResult.data.worksAt;
      });
    }

    if (
      ["TradeBureau", "SubCityOffice"].includes(userRole || "") &&
      selectedWoreda !== "all"
    ) {
      currentCooperatives = currentCooperatives.filter((coop: any) => {
        return coop.woredaOffice?._id === selectedWoreda;
      });
    }

    return currentCooperatives;
  }, [cooperativesData, userRole, userDataResult, selectedWoreda]);

  const shopsGroupedByCooperative = useMemo(() => {
    if (!shopsData?.data || !filteredCooperatives) return {};

    const grouped: { [key: string]: { cooperative: any; shops: any[] } } = {};

    shopsData.data.forEach((shop: any) => {
      const cooperativeId = shop.retailerCooperative?._id;
      const cooperativeDetails = filteredCooperatives.find(
        (coop: any) => coop._id === cooperativeId
      );

      if (cooperativeId && cooperativeDetails) {
        if (!grouped[cooperativeId]) {
          grouped[cooperativeId] = {
            cooperative: cooperativeDetails,
            shops: [],
          };
        }
        grouped[cooperativeId].shops.push(shop);
      }
    });
    return grouped;
  }, [shopsData, filteredCooperatives]);

  const filteredData = useMemo(() => {
    if (!isLoading && !userLoading && data) {
      let currentTransactions = data.data;

      if (ROLES_WITH_NEW_FEATURES.includes(userRole || "")) {
        currentTransactions = currentTransactions.filter((transaction: any) => {
          const transactionDate = new Date(transaction.createdAt);
          const matchesStartDate = appliedStartDate
            ? transactionDate >= appliedStartDate
            : true;
          const matchesEndDate = appliedEndDate
            ? transactionDate <= appliedEndDate
            : true;
          return matchesStartDate && matchesEndDate;
        });
      }

      return currentTransactions
        .filter((transaction: any) => {
          if (userRole === "RetailerCooperativeShop") {
            if (transaction.shopId?._id !== userDataResult?.data?.worksAt) {
              return false;
            }
          }

          if (userRole === "RetailerCooperative") {
            const matchesCooperative =
              transaction.shopId?.retailerCooperative?._id ===
              userDataResult?.data?.worksAt;
            const matchesShop =
              selectedShop === "all" ||
              transaction.shopId?._id === selectedShop;
            if (!(matchesCooperative && matchesShop)) {
              return false;
            }
          }

          let matchesSearch = searchText === "";

          if (!matchesSearch) {
            const searchLower = searchText.toLowerCase();

            if (
              ["TradeBureau", "SubCityOffice", "WoredaOffice"].includes(
                userRole || ""
              )
            ) {
              matchesSearch = transaction.shopId?.retailerCooperative?.name
                ?.toLowerCase()
                .includes(searchLower);
            } else if (userRole === "RetailerCooperative") {
              matchesSearch = transaction.shopId?.name
                ?.toLowerCase()
                .includes(searchLower);
            } else if (userRole === "RetailerCooperativeShop") {
              matchesSearch = transaction.customerId?.name
                ?.toLowerCase()
                .includes(searchLower);
            }
          }

          const matchesCommodity =
            selectedCommodity === "all" ||
            transaction.commodity?.name?.toLowerCase() === selectedCommodity;
          const matchesStatus =
            selectedStatus === "all" ||
            transaction.status?.toLowerCase() === selectedStatus;
          const matchesCooperative =
            selectedCooperative === "all" ||
            transaction.shopId?.retailerCooperative?._id ===
              selectedCooperative;

          const matchesWoreda =
            selectedWoreda === "all" ||
            transaction.shopId?.retailerCooperative?.woredaOffice?._id ===
              selectedWoreda;

          return (
            matchesSearch &&
            matchesCommodity &&
            matchesStatus &&
            matchesCooperative &&
            matchesWoreda
          );
        })
        .sort((a: any, b: any) => {
          return (
            new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
          );
        });
    }
    return [];
  }, [
    isLoading,
    userLoading,
    data,
    searchText,
    selectedCommodity,
    selectedStatus,
    selectedCooperative,
    selectedShop,
    selectedWoreda,
    userRole,
    userDataResult,
    appliedStartDate,
    appliedEndDate,
    ROLES_WITH_NEW_FEATURES,
  ]);

  const groupedTransactions = useMemo(() => {
    return filteredData.reduce((acc: any, transaction: any) => {
      const cooperativeId = transaction.shopId?.retailerCooperative?._id;
      if (!cooperativeId) return acc;

      if (
        !filteredCooperatives.some((coop: any) => coop._id === cooperativeId)
      ) {
        return acc;
      }

      if (!acc[cooperativeId]) {
        acc[cooperativeId] = {
          cooperative: transaction.shopId?.retailerCooperative,
          transactions: [],
        };
      }

      acc[cooperativeId].transactions.push(transaction);
      return acc;
    }, {});
  }, [filteredData, filteredCooperatives]);

  const currentCooperativeShops = useMemo(() => {
    if (
      userRole !== "RetailerCooperative" ||
      !shopsData?.data ||
      !userDataResult?.data?.worksAt
    ) {
      return [];
    }
    return shopsData.data.filter(
      (shop: any) =>
        shop.retailerCooperative?._id === userDataResult.data.worksAt
    );
  }, [shopsData, userRole, userDataResult]);

  const totalTransactions = ROLES_WITH_NEW_FEATURES.includes(userRole || "")
    ? filteredData.length
    : 0;
  const totalQuantitySold = ROLES_WITH_NEW_FEATURES.includes(userRole || "")
    ? filteredData.reduce(
        (sum: number, transaction: any) => sum + (transaction.amount || 0),
        0
      )
    : 0;
  const totalRevenue = ROLES_WITH_NEW_FEATURES.includes(userRole || "")
    ? filteredData.reduce((sum: number, transaction: any) => {
        const quantity = transaction.amount || 0;
        const pricePerUnit = transaction.commodity?.price || 0;
        return sum + quantity * pricePerUnit;
      }, 0)
    : 0;

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
    setSelectedCooperative("all");
    setSelectedShop("all");
    setSelectedWoreda("all");
    setStartDate(undefined);
    setEndDate(undefined);
    setAppliedStartDate(undefined);
    setAppliedEndDate(undefined);
  };

  const isAnyFilterApplied = useMemo(() => {
    return (
      searchText !== "" ||
      selectedCommodity !== "all" ||
      selectedStatus !== "all" ||
      selectedCooperative !== "all" ||
      selectedShop !== "all" ||
      selectedWoreda !== "all" ||
      startDate !== undefined ||
      endDate !== undefined
    );
  }, [
    searchText,
    selectedCommodity,
    selectedStatus,
    selectedCooperative,
    selectedShop,
    selectedWoreda,
    startDate,
    endDate,
  ]);

  if (
    userLoading ||
    isLoadingCurrentShop ||
    isLoading ||
    shopsLoading ||
    cooperativesLoading ||
    isLoadingWoreda
  )
    return <Loader />;

  const handleShopClick = (shopId: string) => {
    router.push(`/dashboard/transactions/shop/${shopId}`);
  };

  const showNewFeatures = ROLES_WITH_NEW_FEATURES.includes(userRole || "");

  return (
    <div className="flex flex-col gap-4">
      <TransactionCreateModal
        showCreateForm={showCreateForm}
        setShowCreateForm={setShowCreateForm}
      />
      <h2 className="text-3xl font-bold tracking-tight">{t("transactions")}</h2>

      {showNewFeatures && (
        <>
          <TransactionSummaryCards
            totalTransactions={totalTransactions}
            totalQuantitySold={totalQuantitySold}
            totalRevenue={totalRevenue}
          />
        </>
      )}

      {userRole === "RetailerCooperativeShop" && currentShopData && (
        <div className="flex justify-between items-center mb-4">
          <div className="mb-2 mr-4 p-2 border rounded bg-gray-50 text-sm">
            <strong>{t("Available Commodities")}:</strong>
            <ul>
              {currentShopData.data.availableCommodity?.map((item: any) => (
                <li key={item.commodity._id}>
                  {item.commodity.name}: {item.quantity} {item.commodity.unit}
                </li>
              ))}
            </ul>
          </div>
          <Button
            className="mb-2"
            onClick={() => setShowCreateForm((prev) => !prev)}
            variant="default"
          >
            {showCreateForm ? t("close") : t("Add Transaction")}
          </Button>
        </div>
      )}

      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between">
        {showNewFeatures && (
          <>
            <TransactionFilters
              userRole={userRole}
              woredas={woredas}
              searchText={searchText}
              setSearchText={setSearchText}
              selectedCommodity={selectedCommodity}
              setSelectedCommodity={setSelectedCommodity}
              selectedWoreda={selectedWoreda}
              setSelectedWoreda={setSelectedWoreda}
              startDate={startDate}
              setStartDate={setStartDate}
              endDate={endDate}
              setEndDate={setEndDate}
              handleSearchDates={handleSearchDates}
              handleClearDates={handleClearDates}
              handleResetFilters={handleResetFilters}
              isAnyFilterApplied={isAnyFilterApplied}
              exportToExcel={exportToExcel}
            />
          </>
        )}
      </div>

      <Card>
        <CardHeader>
          <CardTitle>{t("transactions")}</CardTitle>
          <CardDescription>{t("viewAllTransactions")}</CardDescription>
        </CardHeader>
        <CardContent>
          <TransactionTable
            userRole={userRole}
            filteredData={filteredData}
            groupedTransactions={groupedTransactions}
            shopsGroupedByCooperative={shopsGroupedByCooperative}
            currentCooperativeShops={currentCooperativeShops}
            isLoading={isLoading}
            shopsLoading={shopsLoading}
            cooperativesLoading={cooperativesLoading}
            isAnyFilterApplied={isAnyFilterApplied}
            handleShopClick={handleShopClick}
          />
        </CardContent>
      </Card>
    </div>
  );
}
