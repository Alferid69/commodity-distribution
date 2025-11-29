"use client";
import TransactionCreateForm from "@/components/transaction/transaction-create-form";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { useTranslation } from "react-i18next";

interface TransactionCreateModalProps {
  showCreateForm: boolean;
  setShowCreateForm: (show: boolean) => void;
}

export default function TransactionCreateModal({
  showCreateForm,
  setShowCreateForm,
}: TransactionCreateModalProps) {
  const { t } = useTranslation();

  if (!showCreateForm) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-start sm:items-center justify-center bg-black/30 pt-8 overflow-y-auto max-h-screen">
      <Card className="w-full max-w-lg shadow-2xl relative my-8">
        <CardHeader>
          <CardTitle>{t("Add Transaction")}</CardTitle>
          <Button
            variant="ghost"
            size="icon"
            className="absolute top-2 right-2"
            onClick={() => setShowCreateForm(false)}
            aria-label={t("close")}
          >
            ×
          </Button>
        </CardHeader>

        <CardContent>
          <TransactionCreateForm onSuccess={() => setShowCreateForm(false)} />
        </CardContent>
      </Card>
    </div>
  );
}
