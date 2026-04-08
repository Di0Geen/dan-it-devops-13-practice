from flask import Flask, request, jsonify
import csv
import os

app = Flask(__name__)

CSV_FILE = "students.csv"
FIELDNAMES = ["id", "first_name", "last_name", "age"]

def ensure_csv_exists():
    if not os.path.exists(CSV_FILE):
        with open(CSV_FILE, "w", newline="", encoding="utf-8") as file:
            writer = csv.DictWriter(file, fieldnames=FIELDNAMES)
            writer.writeheader()

def read_students():
    ensure_csv_exists()
    students = []
    with open(CSV_FILE, "r", newline="", encoding="utf-8") as file:
        reader = csv.DictReader(file)
        for row in reader:
            row["id"] = int(row["id"])
            row["age"] = int(row["age"])
            students.append(row)
    return students

def write_students(students):
    with open(CSV_FILE, "w", newline="", encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=FIELDNAMES)
        writer.writeheader()
        for student in students:
            writer.writerow(student)

def get_next_id(students):
    return max([s["id"] for s in students], default=0) + 1


def validate_fields(data, allowed, required=None):
    if not data:
        return "Empty body"

    extra = set(data.keys()) - set(allowed)
    if extra:
        return f"Invalid fields: {extra}"

    if required:
        missing = [f for f in required if f not in data]
        if missing:
            return f"Missing fields: {missing}"

    return None

@app.route("/students", methods=["GET"])
def get_all():
    students = read_students()
    last_name = request.args.get("last_name")

    if last_name:
        res = [s for s in students if s["last_name"].lower() == last_name.lower()]
        if not res:
            return jsonify({"error": "Not found"}), 404
        return jsonify(res)

    return jsonify(students)

@app.route("/students/<int:id>", methods=["GET"])
def get_by_id(id):
    students = read_students()
    student = next((s for s in students if s["id"] == id), None)

    if not student:
        return jsonify({"error": "Not found"}), 404

    return jsonify(student)

@app.route("/students", methods=["POST"])
def create():
    data = request.get_json()

    err = validate_fields(data, ["first_name", "last_name", "age"],
                          ["first_name", "last_name", "age"])
    if err:
        return jsonify({"error": err}), 400

    students = read_students()

    new_student = {
        "id": get_next_id(students),
        "first_name": data["first_name"],
        "last_name": data["last_name"],
        "age": int(data["age"])
    }

    students.append(new_student)
    write_students(students)

    return jsonify(new_student), 201

@app.route("/students/<int:id>", methods=["PUT"])
def update(id):
    data = request.get_json()

    err = validate_fields(data, ["first_name", "last_name", "age"],
                          ["first_name", "last_name", "age"])
    if err:
        return jsonify({"error": err}), 400

    students = read_students()
    student = next((s for s in students if s["id"] == id), None)

    if not student:
        return jsonify({"error": "Not found"}), 404

    student.update({
        "first_name": data["first_name"],
        "last_name": data["last_name"],
        "age": int(data["age"])
    })

    write_students(students)
    return jsonify(student)

@app.route("/students/<int:id>", methods=["PATCH"])
def patch(id):
    data = request.get_json()

    err = validate_fields(data, ["age"], ["age"])
    if err:
        return jsonify({"error": err}), 400

    students = read_students()
    student = next((s for s in students if s["id"] == id), None)

    if not student:
        return jsonify({"error": "Not found"}), 404

    student["age"] = int(data["age"])
    write_students(students)

    return jsonify(student)

@app.route("/students/<int:id>", methods=["DELETE"])
def delete(id):
    students = read_students()
    student = next((s for s in students if s["id"] == id), None)

    if not student:
        return jsonify({"error": "Not found"}), 404

    students = [s for s in students if s["id"] != id]
    write_students(students)

    return jsonify({"message": f"Deleted student {id}"})

if __name__ == "__main__":
    ensure_csv_exists()
    app.run(host="0.0.0.0", port=8000, debug=True)