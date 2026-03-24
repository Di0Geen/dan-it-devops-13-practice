import requests
BASE_URL = "http://127.0.0.1:5001/students"
def log(title, r):
    print("\n" + "="*50)
    print(title)
    print("STATUS:", r.status_code)
    print(r.json())
    
# 1 GET
r = requests.get(BASE_URL)
log("GET all", r)

# 2 POST
s1 = requests.post(BASE_URL, json={
    "first_name": "Ivan", "last_name": "Petrenko", "age": 20
})
s2 = requests.post(BASE_URL, json={
    "first_name": "Olena", "last_name": "Shevchenko", "age": 21
})
s3 = requests.post(BASE_URL, json={
    "first_name": "Mykhailo", "last_name": "Kovalchuk", "age": 22
})

log("POST 1", s1)
log("POST 2", s2)
log("POST 3", s3)

id1 = s1.json()["id"]
id2 = s2.json()["id"]
id3 = s3.json()["id"]

# 3 GET
log("GET all", requests.get(BASE_URL))

# 4 PATCH
log("PATCH", requests.patch(f"{BASE_URL}/{id2}", json={"age": 30}))

# 5 GET by id
log("GET second", requests.get(f"{BASE_URL}/{id2}"))

# 6 PUT
log("PUT", requests.put(f"{BASE_URL}/{id3}", json={
    "first_name": "Misha",
    "last_name": "Bondarenko",
    "age": 35
}))

# 7 GET
log("GET third", requests.get(f"{BASE_URL}/{id3}"))

# 8 GET all
log("GET all", requests.get(BASE_URL))

# 9 DELETE
log("DELETE", requests.delete(f"{BASE_URL}/{id1}"))

# 10 GET all
log("GET all", requests.get(BASE_URL))