"use client";
import { Button } from "@/components/ui/button";
import { Calendar } from "@/components/ui/calendar";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
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
import { format } from "date-fns";
import { CalendarIcon, Download, Search, XCircle } from "lucide-react";
import { useTranslation } from "react-i18next";

interface TransactionFiltersProps {
  userRole: string | null;
  woredas: any;
  searchText: string;
  setSearchText: (value: string) => void;
  selectedCommodity: string;
  setSelectedCommodity: (value: string) => void;
  selectedWoreda: string;
  setSelectedWoreda: (value: string) => void;
  startDate: Date | undefined;
  setStartDate: (date: Date | undefined) => void;
  endDate: Date | undefined;
  setEndDate: (date: Date | undefined) => void;
  handleSearchDates: () => void;
  handleClearDates: () => void;
  handleResetFilters: () => void;
  isAnyFilterApplied: boolean;
  exportToExcel: ()=>void;
}

export default function TransactionFilters({
  userRole,
  woredas,
  searchText,
  setSearchText,
  selectedCommodity,
  setSelectedCommodity,
  selectedWoreda,
  setSelectedWoreda,
  startDate,
  setStartDate,
  endDate,
  setEndDate,
  handleSearchDates,
  handleClearDates,
  handleResetFilters,
  isAnyFilterApplied,
  exportToExcel,
}: TransactionFiltersProps) {
  const { t } = useTranslation();

  return (
    <>
      <div className="min-w-full flex flex-col sm:flex-row sm:items-center sm:justify-between">
        <div className="flex w-full flex-wrap items-center justify-between sm:mt-0">
          <div className="flex gap-3">
            {(userRole === "RetailerCooperativeShop" ||
              userRole === "RetailerCooperative") && (
              <Button
                className="w-fit"
                onClick={exportToExcel}
                variant="default"
              >
                <Download />
                {t("exportX")}
              </Button>
            )}
          </div>
          <div className="flex items-center gap-2">
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
              {t("Apply Date Filter")}
            </Button>
            {isAnyFilterApplied && (
              <Button variant="outline" size="sm" onClick={handleResetFilters}>
                <XCircle className="mr-2 h-4 w-4" />
                {t("Reset Filters")}
              </Button>
            )}
          </div>

          {/* Date Range Feedback */}
          <div className="w-full text-sm text-muted-foreground text-right pr-2">
            {startDate || endDate
              ? `${t("Showing data from")} ${
                  startDate ? format(startDate, "PPP") : t("the beginning")
                } ${t("To")} ${endDate ? format(endDate, "PPP") : t("now")}`
              : t("Showing all dates")}
          </div>
          <div className="w-full flex items-center justify-around gap-4">
            <div className="relative flex-1">
              <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
              <Input
                type="search"
                placeholder={t("searchTransactions")}
                className="w-full pl-8"
                value={searchText}
                onChange={(e) => setSearchText(e.target.value)}
              />
            </div>
            {userRole === "RetailerCooperativeShop" && (
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
            )}
          </div>
        </div>

        <div className="grid grid-cols-2 gap-2 sm:flex mt-4 sm:mt-0">
          {/* Woreda Filter for TradeBureau and SubCityOffice */}
          {["TradeBureau", "SubCityOffice"].includes(userRole || "") && (
            <div>
              <Label htmlFor="woreda" className="sr-only">
                {t("Woreda")}
              </Label>
              <Select value={selectedWoreda} onValueChange={setSelectedWoreda}>
                <SelectTrigger id="woreda" className="w-full sm:w-[150px]">
                  <SelectValue placeholder={t("Woreda")} />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">{t("All Woredas")}</SelectItem>
                  {woredas?.data?.map((woreda: any) => (
                    <SelectItem key={woreda._id} value={woreda._id}>
                      {woreda.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          )}

          {/* Commodity filter for RetailerCooperativeShop */}
        </div>
      </div>
    </>
  );
}
