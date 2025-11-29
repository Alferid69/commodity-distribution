import api from "@/lib/api";

// Get all transactions
export async function getTransactions(token: any) {
  try {
    const res = await api.get("/transactions", {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });
    return res.data;
  } catch (error) {
    console.error("Error fetching all transactions:", error);
    throw error;
  }
}

// Get a single transaction by ID
export async function getTransaction(token: any, transactionId: string) {
  try {
    const res = await api.get(`/transactions/${transactionId}`, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });
    return res.data;
  } catch (error) {
    console.error(`Error fetching transaction with ID ${transactionId}:`, error);
    throw error;
  }
}

// Get transactions by shop ID (with optional date range)
export async function getTransactionsByShopId(
  token: string | null,
  shopId: string,
  startDate?: Date,
  endDate?: Date
) {
  try {
    const params: { [key: string]: string } = {};
    if (startDate) params.start = startDate.toISOString();
    if (endDate) params.end = endDate.toISOString();

    const response = await api.get(`/transactions/shop/${shopId}`, {
      params,
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });
    return response.data;
  } catch (error) {
    console.error(`Error fetching transactions for shop ${shopId}:`, error);
    throw error;
  }
}

// Get transactions by general date range (with optional shop ID)
export async function getTransactionsByDateRange(
  token: string | null,
  start?: string,
  end?: string,
  shopId?: string
) {
  try {
    const params = new URLSearchParams();
    if (start) params.append("start", start);
    if (end) params.append("end", end);
    if (shopId) params.append("shopId", shopId);

    const res = await api.get(`/transactions/date?${params.toString()}`, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });
    return res.data;
  } catch (error) {
    console.error("Error fetching transactions by date range:", error);
    throw error;
  }
}

// Create a new transaction
export async function createTransaction(token: any, transactionData: any) {
  try {
    const res = await api.post("/transactions", transactionData, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });
    return res.data;
  } catch (error) {
    console.error("Error creating transaction:", error);
    throw error;
  }
}

// Update a transaction
export async function updateTransaction(token: any, transactionId: string, transactionData: any) {
  try {
    const res = await api.patch(`/transactions/${transactionId}`, transactionData, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });
    return res.data;
  } catch (error) {
    console.error(`Error updating transaction ${transactionId}:`, error);
    throw error;
  }
}

// Delete a transaction
export async function deleteTransaction(token: any, transactionId: string) {
  try {
    const res = await api.delete(`/transactions/${transactionId}`, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });
    return res.data;
  } catch (error) {
    console.error(`Error deleting transaction ${transactionId}:`, error);
    throw error;
  }
}
