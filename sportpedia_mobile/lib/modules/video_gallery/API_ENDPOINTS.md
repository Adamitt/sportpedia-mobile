# API Endpoints untuk Modul Video Gallery

Dokumentasi endpoint API yang diperlukan untuk integrasi Flutter dengan Django backend.

## Endpoint yang Sudah Ada (Pekan 2)

### 1. GET /videos/api/
**Deskripsi:** Mengambil daftar semua video  
**Response:** Array of Video objects (JSON)

### 2. GET /videos/api/{id}/
**Deskripsi:** Mengambil detail satu video  
**Response:** Video object (JSON)

---

## Endpoint yang Perlu Ditambahkan (Pekan 3)

### 3. GET /videos/api/?sport={sport_id}&difficulty={difficulty}
**Deskripsi:** Mengambil daftar video dengan filter  
**Query Parameters:**
- `sport` (optional): ID olahraga (int)
- `difficulty` (optional): Level kesulitan ("Pemula", "Menengah", "Lanjutan")

**Contoh Request:**
```
GET /videos/api/?sport=1&difficulty=Pemula
```

**Response:** Array of Video objects (JSON)

**Catatan:** Endpoint ini bisa menggunakan endpoint yang sama dengan `GET /videos/api/` dengan menambahkan query parameters.

---

### 4. GET /videos/api/{id}/comments/
**Deskripsi:** Mengambil daftar komentar untuk video tertentu  
**Response:** Array of Comment objects (JSON)

**Format Response:**
```json
[
  {
    "id": 1,
    "user": "username",
    "text": "Komentar text",
    "rating": 5,
    "helpful_count": 3,
    "created_at": "2025-11-26 10:30:00"
  }
]
```

---

### 5. POST /videos/api/{id}/comment/
**Deskripsi:** Menambahkan komentar baru untuk video  
**Request Body:**
```json
{
  "text": "Komentar text",
  "rating": 5  // optional, 1-5
}
```

**Response:** Comment object (JSON)

**Status Codes:**
- 200/201: Success
- 400: Bad Request (text kosong, dll)
- 401: Unauthorized (perlu login)

---

### 6. POST /videos/api/{id}/rate/
**Deskripsi:** Menambahkan rating untuk video  
**Request Body:**
```json
{
  "rating": 5  // 1-5
}
```

**Response:** 
```json
{
  "success": true,
  "message": "Rating berhasil disimpan"
}
```

**Status Codes:**
- 200/201: Success
- 400: Bad Request (rating tidak valid)
- 401: Unauthorized (perlu login)

---

## Implementasi di Django

### Contoh View untuk Filter (update `api_video_list`):

```python
@require_GET
def api_video_list(request):
    videos = load_videos()
    
    # Filter by sport
    sport_id = request.GET.get('sport')
    if sport_id:
        try:
            sport_id = int(sport_id)
            videos = [v for v in videos if v.get('sport_id') == sport_id]
        except ValueError:
            pass
    
    # Filter by difficulty
    difficulty = request.GET.get('difficulty')
    if difficulty:
        videos = [v for v in videos if v.get('difficulty') == difficulty]
    
    # ... rest of code
    return JsonResponse(videos, safe=False)
```

### Contoh View untuk Comments:

```python
@require_GET
def api_video_comments(request, video_id):
    comments = load_comments()
    video_comments = [c for c in comments if c.get('video_id') == video_id]
    return JsonResponse(video_comments, safe=False)

@require_POST
def api_video_add_comment(request, video_id):
    data = json.loads(request.body)
    text = data.get('text', '').strip()
    rating = data.get('rating')
    
    if not text:
        return JsonResponse({'error': 'Text required'}, status=400)
    
    # Save comment logic here
    new_comment = {
        'id': int(datetime.now().timestamp()),
        'user': request.user.username if request.user.is_authenticated else 'anonymous',
        'text': text,
        'rating': rating,
        'helpful_count': 0,
        'created_at': datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
    }
    
    # Save to JSON file or database
    # ...
    
    return JsonResponse(new_comment, status=201)
```

### Update URLs:

```python
urlpatterns = [
    # ... existing patterns
    path('api/', views.api_video_list, name='api_video_list'),
    path('api/<int:video_id>/', views.api_video_detail, name='api_video_detail'),
    path('api/<int:video_id>/comments/', views.api_video_comments, name='api_video_comments'),
    path('api/<int:video_id>/comment/', views.api_video_add_comment, name='api_video_add_comment'),
    path('api/<int:video_id>/rate/', views.api_video_rate, name='api_video_rate'),
]
```

---

## Testing

Setelah endpoint dibuat, test dengan:

1. **Filter:**
   ```
   http://127.0.0.1:8000/videos/api/?sport=1
   http://127.0.0.1:8000/videos/api/?difficulty=Pemula
   http://127.0.0.1:8000/videos/api/?sport=1&difficulty=Pemula
   ```

2. **Comments:**
   ```
   GET http://127.0.0.1:8000/videos/api/1/comments/
   ```

3. **Add Comment (via Postman/curl):**
   ```
   POST http://127.0.0.1:8000/videos/api/1/comment/
   Body: {"text": "Great video!", "rating": 5}
   ```

4. **Rate Video:**
   ```
   POST http://127.0.0.1:8000/videos/api/1/rate/
   Body: {"rating": 5}
   ```

