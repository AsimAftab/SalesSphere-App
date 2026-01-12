# Odometer API Integration Design

**Date:** 2026-01-13
**Feature:** Integrate odometer start/stop endpoints with location tracking and image upload

## API Endpoints

### 1. Today's Status
```
GET /api/v1/odometer/status/today
```

**Response (no active trip):**
```json
{
  "success": true,
  "data": null,
  "message": "No odometer reading for today",
  "status": "not_started",
  "organizationTimezone": "Asia/Kolkata"
}
```

**Response (active trip):**
```json
{
  "success": true,
  "data": { /* odometer object */ },
  "status": "in_progress",
  "organizationTimezone": "Asia/Kolkata"
}
```

### 2. Start Reading
```
POST /api/v1/odometer/start
```

**Request:**
```json
{
  "startReading": 15000,
  "startUnit": "km",
  "startDescription": "Starting from office",
  "latitude": 28.6139,
  "longitude": 77.2090,
  "address": "New Delhi, India"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Start reading recorded successfully",
  "data": {
    "_id": "696555a41574ed4e9b849c39",
    "startReading": 15000,
    "startUnit": "km",
    "startDescription": "Starting from office",
    "startTime": "2026-01-12T20:12:19.841Z",
    "status": "in_progress",
    "startLocation": {
      "latitude": 28.6139,
      "longitude": 77.209,
      "address": "New Delhi, India"
    }
  }
}
```

### 3. Upload Start Image
```
POST /api/v1/odometer/{id}/start-image
```

**Request:** Multipart with `image` field

**Response:**
```json
{
  "success": true,
  "message": "Start image uploaded successfully",
  "data": {
    "startImage": "https://res.cloudinary.com/.../start_image.jpg"
  }
}
```

### 4. Stop Reading
```
PUT /api/v1/odometer/stop
```

**Request:**
```json
{
  "stopReading": 15085,
  "stopUnit": "km",
  "stopDescription": "Returned to office",
  "latitude": 28.6139,
  "longitude": 77.2090,
  "address": "New Delhi, India"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Stop reading recorded successfully",
  "data": {
    "status": "completed",
    "stopReading": 15085,
    "stopTime": "2026-01-12T20:14:19.830Z",
    "stopLocation": { ... }
  }
}
```

### 5. Upload Stop Image
```
POST /api/v1/odometer/{id}/stop-image
```

## Model Changes

### New Models
- `OdometerTodayStatusResponse` - Wrapper for today's status API
- `StartLocation` - Location object for start
- `StopLocation` - Location object for stop

### Updated OdometerReading
Add fields to match API:
- `startLocation` (StartLocation)
- `stopLocation` (StopLocation?)
- `tripStatus` (String?) - "in_progress" or "completed"
- Rename `description` → `startDescription` in API mapping
- Add `stopUnit` field

## ViewModel Implementation

### OdometerViewModel

**build()**
- Fetch today's status from `/api/v1/odometer/status/today`
- Return `OdometerReading?` (null if no active trip)

**startTrip()**
1. Get current location via `LocationService`
2. Get address via `GeocodingService`
3. POST to `/api/v1/odometer/start` with reading + location
4. Upload image to `/api/v1/odometer/{id}/start-image`
5. Refresh state

**stopTrip()**
1. Get current location
2. Get address
3. PUT to `/api/v1/odometer/stop` with stop reading + location
4. Upload stop image
5. Reset state to null

## Screen Changes

### OdometerReadingForm
- **Remove:** Location/address input fields
- **Keep:** Reading input, unit toggle (KM/MILES), image picker, description
- Location capture happens automatically on submit (like attendance)

### Error Handling
- Follow attendance pattern: show loading dialog, capture location, handle errors gracefully
- Use ConnectivityInterceptor for offline detection

## Implementation Order

1. Add odometer endpoints to `ApiEndpoints`
2. Update models in `odometer.model.dart`
3. Implement API calls in `odometer.vm.dart`
4. Update screen to remove location inputs
5. Run code generation
6. Test start/stop flow
