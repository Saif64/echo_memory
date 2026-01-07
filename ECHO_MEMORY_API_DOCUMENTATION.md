# Echo Memory Backend API Documentation

> **Complete REST API Reference for Echo Memory**

---

## Base URL
```
/api/v1/echo-memory
```

## Standard Response Format
All endpoints follow the existing `ApiResponse` format:
```json
{
  "success": true/false,
  "message": "Description message",
  "data": {...},
  "error": "ERROR_CODE",
  "timestamp": 1699999999999
}
```

---

## 1. Authentication

### 1.1 Guest Login
Create anonymous guest account for immediate play.

**Endpoint:** `POST /api/v1/echo-memory/auth/guest`

**Request:**
```json
{
  "displayName": "Player123"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJ...",
    "refreshToken": "eyJ...",
    "expiresIn": 900,
    "user": {
      "id": "uuid",
      "displayName": "Player123",
      "authProvider": "GUEST",
      "isGuest": true
    }
  }
}
```

### 1.2 Google Login
Login or register with Google OAuth.

**Endpoint:** `POST /api/v1/echo-memory/auth/google`

**Request:**
```json
{
  "idToken": "google-id-token",
  "displayName": "Optional Name"
}
```

### 1.3 Email Registration
**Endpoint:** `POST /api/v1/echo-memory/auth/register`

**Request:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "displayName": "Player123"
}
```

### 1.4 Email Login
**Endpoint:** `POST /api/v1/echo-memory/auth/login`

**Request:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

### 1.5 Link Guest Account
Upgrade guest account to permanent (Google/Email).

**Endpoint:** `POST /api/v1/echo-memory/auth/link`  
**Auth:** Required (JWT)

**Request:**
```json
{
  "linkType": "google",
  "googleIdToken": "token"
}
```
or
```json
{
  "linkType": "email",
  "email": "user@example.com",
  "password": "password123"
}
```

### 1.6 Refresh Token
**Endpoint:** `POST /api/v1/echo-memory/auth/refresh`

**Request:**
```json
{
  "refreshToken": "refresh-token"
}
```

---

## 2. Economy

### 2.1 Get Economy State
Get coins, gems, and lives (server-calculated).

**Endpoint:** `GET /api/v1/echo-memory/economy/state`  
**Auth:** Required

**Response:**
```json
{
  "success": true,
  "data": {
    "coins": 150,
    "gems": 25,
    "lives": 18,
    "maxLives": 20,
    "nextLifeAt": "2026-01-06T12:30:00Z",
    "livesFullAt": "2026-01-06T13:30:00Z",
    "dailyBonusAvailable": true,
    "dailyLoginStreak": 3
  }
}
```

### 2.2 Use Life
Consume a life to start a game.

**Endpoint:** `POST /api/v1/echo-memory/economy/use-life`  
**Auth:** Required

**Request:**
```json
{
  "gameMode": "classic"
}
```

### 2.3 Buy Lives
Purchase lives with gems or coins.

**Endpoint:** `POST /api/v1/echo-memory/economy/buy-lives`  
**Auth:** Required

**Request:**
```json
{
  "quantity": 5,
  "currency": "gems"
}
```

### 2.4 Claim Daily Bonus
**Endpoint:** `POST /api/v1/echo-memory/economy/claim-daily`  
**Auth:** Required

---

## 3. Game Sessions

### 3.1 Start Game
**Endpoint:** `POST /api/v1/echo-memory/game/start`  
**Auth:** Required

**Request:**
```json
{
  "gameMode": "classic",
  "difficulty": "expert"
}
```

### 3.2 End Game
**Endpoint:** `POST /api/v1/echo-memory/game/end`  
**Auth:** Required

**Request:**
```json
{
  "gameMode": "classic",
  "score": 1250,
  "level": 12,
  "streak": 8,
  "durationSeconds": 180,
  "powerUpsUsed": ["hint"]
}
```

---

## 4. Leaderboards

### 4.1 Get All-Time Leaderboard (Public)
**Endpoint:** `GET /api/v1/echo-memory/leaderboard/{mode}`

**Path Parameters:** `mode` = `classic`, `stream`, `lumina`, `reflex`

### 4.2 Get Weekly Leaderboard (Public)
**Endpoint:** `GET /api/v1/echo-memory/leaderboard/{mode}/weekly`

### 4.3 Get User Ranks
**Endpoint:** `GET /api/v1/echo-memory/leaderboard/me`  
**Auth:** Required

---

## 5. Daily Challenges

### 5.1 Get Today's Challenge
**Endpoint:** `GET /api/v1/echo-memory/daily/today`  
**Auth:** Required

**Response:**
```json
{
  "success": true,
  "data": {
    "date": "2026-01-06",
    "gameMode": "CLASSIC",
    "config": {
      "difficulty": "expert",
      "seed": 20260106,
      "sequenceLength": 6,
      "targetScore": 500
    },
    "targetScore": 500,
    "completed": false,
    "userBestScore": 0,
    "streakInfo": {
      "currentStreak": 3,
      "longestStreak": 7,
      "totalCompleted": 15
    }
  }
}
```

### 5.2 Submit Challenge Completion
**Endpoint:** `POST /api/v1/echo-memory/daily/complete`  
**Auth:** Required

**Request:**
```json
{
  "score": 650,
  "durationSeconds": 120,
  "powerUpsUsed": []
}
```

### 5.3 Get Streak Info
**Endpoint:** `GET /api/v1/echo-memory/daily/streak`  
**Auth:** Required

---

## 6. Cloud Save (Sync)

### 6.1 Pull Server State
**Endpoint:** `GET /api/v1/echo-memory/sync/pull`  
**Auth:** Required

### 6.2 Push Client State
**Endpoint:** `POST /api/v1/echo-memory/sync/push`  
**Auth:** Required

**Request:**
```json
{
  "totalGamesPlayed": 150,
  "totalScore": 45000,
  "highScore": 1250,
  "bestStreak": 15,
  "longestSequence": 12,
  "totalPlayTimeSeconds": 36000,
  "modeHighScores": {
    "classic": 1250,
    "stream": 890
  }
}
```

---

## 7. Shop

### 7.1 Get Shop Items
**Endpoint:** `GET /api/v1/echo-memory/shop/items`  
**Auth:** Required

### 7.2 Purchase Item
**Endpoint:** `POST /api/v1/echo-memory/shop/buy`  
**Auth:** Required

**Request:**
```json
{
  "itemId": "lives_5"
}
```

### 7.3 Open Chest
**Endpoint:** `POST /api/v1/echo-memory/shop/open-chest`  
**Auth:** Required

**Request:**
```json
{
  "chestId": "gold"
}
```

---

## 8. In-App Purchases

### 8.1 Verify Purchase
**Endpoint:** `POST /api/v1/echo-memory/iap/verify`  
**Auth:** Required

**Request:**
```json
{
  "store": "google",
  "productId": "gems_500",
  "receipt": "purchase-token",
  "orderId": "GPA.1234"
}
```

### 8.2 Get IAP Products
**Endpoint:** `GET /api/v1/echo-memory/iap/products`

---

## 9. Remote Config (Public)

### 9.1 Get All Config
**Endpoint:** `GET /api/v1/echo-memory/config`

**Response:**
```json
{
  "success": true,
  "data": {
    "max_lives": "20",
    "life_regen_minutes": "30",
    "daily_bonus_coins": "50",
    "maintenance_mode": "false"
  }
}
```

---

## Authentication
For protected endpoints, include JWT in Authorization header:
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6...
```

## Error Codes
| Code | Description |
|------|-------------|
| `UNAUTHORIZED` | Invalid/missing JWT token |
| `GUEST_CREATION_FAILED` | Failed to create guest account |
| `GOOGLE_AUTH_FAILED` | Google token verification failed |
| `INVALID_CREDENTIALS` | Wrong email/password |
| `NO_LIVES` | No lives available |
| `PURCHASE_FAILED` | Insufficient funds |
| `VERIFICATION_FAILED` | IAP receipt invalid |
