"use client";
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { useTranslation } from "react-i18next";

interface TransactionSummaryCardsProps {
  totalTransactions: number;
  totalQuantitySold: number;
  totalRevenue: number;
}

export default function TransactionSummaryCards({
  totalTransactions,
  totalQuantitySold,
  totalRevenue,
}: TransactionSummaryCardsProps) {
  const { t } = useTranslation();

  return (
    <div className="mt-4 grid grid-cols-1 md:grid-cols-3 gap-4">
      <Card className="text-center">
        <CardHeader>
          <CardTitle className="text-lg">{t("Total Transactions")}</CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-2xl font-bold">{totalTransactions}</p>
        </CardContent>
      </Card>
      <Card className="text-center">
        <CardHeader>
          <CardTitle className="text-lg">{t("Total Quantity Sold")}</CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-2xl font-bold">{totalQuantitySold.toFixed(2)} {t("units")}</p>
        </CardContent>
      </Card>
      <Card className="text-center">
        <CardHeader>
          <CardTitle className="text-lg">{t("Total Revenue")}</CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-2xl font-bold">{totalRevenue.toFixed(2)} {t("currency")}</p>
        </CardContent>
      </Card>
    </div>
  );
}
