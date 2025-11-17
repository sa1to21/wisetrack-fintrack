# 🔄 Архитектура потока данных - FinTrack

**Дата:** 2025-10-05
**Версия:** 1.0

---

## 📊 Текущая архитектура (с моками)

```
┌─────────────────────────────────────────────────────────┐
│                     Telegram Mini App                     │
│                  (https://wisetrack21.site/)              │
└─────────────────────────────────────────────────────────┘
                            │
                            │ 1. Открытие приложения
                            ▼
┌─────────────────────────────────────────────────────────┐
│            TelegramAuthContext.tsx                       │
│  • Инициализация Telegram SDK                           │
│  • Получение initData                                   │
└─────────────────────────────────────────────────────────┘
                            │
                            │ 2. POST /api/auth/telegram
                            ▼
┌─────────────────────────────────────────────────────────┐
│           Rails API (через ngrok)                        │
│    https://b456016d6bd1.ngrok-free.app                  │
│                                                          │
│  TelegramAuthController:                                │
│  • Создать/найти пользователя                          │
│  • Генерировать JWT токен                              │
│  • Вернуть: { token, user }                            │
└─────────────────────────────────────────────────────────┘
                            │
                            │ 3. Сохранить токен в localStorage
                            ▼
┌─────────────────────────────────────────────────────────┐
│                    App.tsx                               │
│                                                          │
│  🎭 МОКИ:                                               │
│  const [transactions] = useState([                      │
│    { id: "1", type: "expense", ... },                  │
│    { id: "2", type: "income", ... }                    │
│  ])                                                     │
└─────────────────────────────────────────────────────────┘
                            │
                            │ 4. Передача данных в компоненты
                            ▼
┌─────────────────────────────────────────────────────────┐
│               DashboardPage.tsx                          │
│                                                          │
│  🎭 МОКИ:                                               │
│  const [accounts] = useState([                          │
│    { id: "1", name: "Основной счёт", balance: 25430 },│
│    { id: "2", name: "Накопления", balance: 8750 }     │
│  ])                                                     │
└─────────────────────────────────────────────────────────┘
```

**Проблемы:**
- ❌ Данные не сохраняются (пропадают при перезагрузке)
- ❌ Нет синхронизации между устройствами
- ❌ API endpoints готовы, но не используются

---

## 🎯 Целевая архитектура (с API)

```
┌─────────────────────────────────────────────────────────┐
│                     Telegram Mini App                     │
│                  (https://wisetrack21.site/)              │
└─────────────────────────────────────────────────────────┘
                            │
                            │ 1. Открытие приложения
                            ▼
┌─────────────────────────────────────────────────────────┐
│            TelegramAuthContext.tsx                       │
│  • Инициализация Telegram SDK                           │
│  • Получение initData                                   │
└─────────────────────────────────────────────────────────┘
                            │
                            │ 2. POST /api/auth/telegram
                            ▼
┌─────────────────────────────────────────────────────────┐
│           Rails API (Production)                         │
│         https://fintrack-api.railway.app                │
│                                                          │
│  TelegramAuthController:                                │
│  if user.new_record?                                    │
│    user.save!                                          │
│    user.accounts.create!(...)      # Дефолтный счет    │
│    create_default_categories(user) # 9 категорий       │
│  end                                                    │
│                                                          │
│  • Вернуть: { token, user }                            │
└─────────────────────────────────────────────────────────┘
                            │
                            │ 3. JWT токен → localStorage
                            ▼
┌─────────────────────────────────────────────────────────┐
│                    App.tsx                               │
│                                                          │
│  useEffect(() => {                                      │
│    if (isAuthenticated) {                              │
│      loadData();                                       │
│    }                                                    │
│  }, [isAuthenticated]);                                │
└─────────────────────────────────────────────────────────┘
                            │
            ┌───────────────┼────────────────┐
            │               │                │
            ▼               ▼                ▼
    ┌──────────┐    ┌──────────┐    ┌──────────┐
    │   GET    │    │   GET    │    │   GET    │
    │ /accounts│    │/categories│    │/transact.│
    └──────────┘    └──────────┘    └──────────┘
            │               │                │
            └───────────────┼────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                 DashboardPage.tsx                        │
│                                                          │
│  ✅ Данные из API:                                      │
│  const [accounts, setAccounts] = useState([]);          │
│  const [transactions, setTransactions] = useState([]);  │
│                                                          │
│  useEffect(() => {                                      │
│    accountsService.getAll().then(setAccounts);          │
│    transactionsService.getAll().then(setTransactions);  │
│  }, []);                                                │
└─────────────────────────────────────────────────────────┘
```

---

## 🔄 Flow создания транзакции

### Текущий (моки):
```
User → AddTransactionPage
         │
         │ onSubmit({ amount, type, ... })
         ▼
      App.tsx
         │
         │ setTransactions([...prev, new])
         ▼
   Локальный стейт
         │
         │ ❌ Пропадет при перезагрузке
         ▼
   DashboardPage (обновится)
```

### Целевой (API):
```
User → AddTransactionPage
         │
         │ onSubmit({ amount, type, ... })
         ▼
   transactionsService.create({
     amount, transaction_type, description,
     date, account_id, category_id
   })
         │
         │ POST /api/transactions
         │ Headers: { Authorization: "Bearer JWT_TOKEN" }
         ▼
   Rails API
         │
         │ TransactionsController#create
         │ current_user.transactions.create!(...)
         ▼
   PostgreSQL Database
         │
         │ return { id, amount, ... }
         ▼
   Frontend
         │
         │ setTransactions([...prev, newTransaction])
         │ ✅ Данные сохранены в БД!
         ▼
   DashboardPage (обновится)
```

---

## 🗄️ Схема базы данных

```sql
┌─────────────────┐
│      users      │
├─────────────────┤
│ id (integer)    │──┐
│ name            │  │
│ email           │  │
│ telegram_id     │  │
│ username        │  │
│ language_code   │  │
│ created_at      │  │
│ updated_at      │  │
└─────────────────┘  │
                     │
        ┌────────────┴─────────────┐
        │                          │
        ▼                          ▼
┌─────────────────┐       ┌─────────────────┐
│    accounts     │       │   categories    │
├─────────────────┤       ├─────────────────┤
│ id (uuid)       │──┐    │ id (uuid)       │
│ user_id         │  │    │ user_id         │
│ name            │  │    │ name            │
│ balance         │  │    │ category_type   │
│ currency        │  │    │ icon            │
│ account_type    │  │    │ color           │
│ created_at      │  │    │ created_at      │
│ updated_at      │  │    │ updated_at      │
└─────────────────┘  │    └─────────────────┘
                     │             │
        ┌────────────┴─────────────┘
        │
        ▼
┌─────────────────┐
│  transactions   │
├─────────────────┤
│ id (uuid)       │
│ account_id      │
│ category_id     │
│ amount          │
│ transaction_type│  # 'income' | 'expense'
│ description     │
│ date            │
│ created_at      │
│ updated_at      │
└─────────────────┘
```

---

## 📡 API Endpoints

### Авторизация
```
POST /api/auth/telegram
Body: {
  init_data: "...",
  user: { telegram_id, first_name, ... }
}
Response: { token, user }
```

### Категории
```
GET    /api/categories
POST   /api/categories
GET    /api/categories/:id
PUT    /api/categories/:id
DELETE /api/categories/:id
```

### Счета
```
GET    /api/accounts
POST   /api/accounts
GET    /api/accounts/:id
PUT    /api/accounts/:id
DELETE /api/accounts/:id
```

### Транзакции
```
GET    /api/transactions
GET    /api/transactions?start_date=...&end_date=...
POST   /api/transactions
GET    /api/transactions/:id
PUT    /api/transactions/:id
DELETE /api/transactions/:id
GET    /api/transactions/stats
```

---

## 🔐 Авторизация

```
┌─────────────────────────────────────────────────────────┐
│  Каждый запрос к API (кроме /auth/telegram)             │
└─────────────────────────────────────────────────────────┘
                            │
                            │ Headers: {
                            │   Authorization: "Bearer eyJhbGci..."
                            │ }
                            ▼
┌─────────────────────────────────────────────────────────┐
│           ApplicationController                          │
│                                                          │
│  before_action :authenticate_request                    │
│                                                          │
│  def authenticate_request                               │
│    header = request.headers['Authorization']           │
│    token = header.split(' ').last                      │
│    decoded = JWT.decode(token, secret_key)             │
│    @current_user = User.find(decoded['user_id'])       │
│  rescue JWT::DecodeError                               │
│    render json: { error: 'Invalid token' }, status: 401│
│  end                                                    │
└─────────────────────────────────────────────────────────┘
```

---

## ⚡ Оптимизация

### Кэширование с React Query
```typescript
import { useQuery, useMutation } from '@tanstack/react-query';

// Загрузка транзакций с автоматическим кэшированием
const { data: transactions, isLoading } = useQuery({
  queryKey: ['transactions'],
  queryFn: () => transactionsService.getAll()
});

// Создание транзакции с автоматическим обновлением кэша
const createMutation = useMutation({
  mutationFn: transactionsService.create,
  onSuccess: () => {
    queryClient.invalidateQueries(['transactions']);
  }
});
```

### Оптимистичные обновления
```typescript
const updateMutation = useMutation({
  mutationFn: ({ id, data }) => transactionsService.update(id, data),

  // Оптимистично обновляем UI до ответа сервера
  onMutate: async (newData) => {
    await queryClient.cancelQueries(['transactions']);
    const previousData = queryClient.getQueryData(['transactions']);

    queryClient.setQueryData(['transactions'], (old) =>
      old.map(t => t.id === newData.id ? { ...t, ...newData.data } : t)
    );

    return { previousData };
  },

  // Откатываем при ошибке
  onError: (err, newData, context) => {
    queryClient.setQueryData(['transactions'], context.previousData);
  }
});
```

---

## 📱 Offline Support (будущее)

```
┌─────────────────────────────────────────────────────────┐
│              Service Worker + IndexedDB                  │
│                                                          │
│  • Кэш API ответов                                      │
│  • Очередь pending запросов                             │
│  • Синхронизация при восстановлении связи               │
└─────────────────────────────────────────────────────────┘
```

---

Последнее обновление: 2025-10-05 01:25 MSK
