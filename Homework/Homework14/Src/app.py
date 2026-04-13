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


@app.route("/students", methods=["GET"])
def get_all_students():
    students = read_students()
    last_name = request.args.get("last_name")

    if last_name:
        filtered = [s for s in students if s["last_name"].lower() == last_name.lower()]
        if not filtered:
            return jsonify({"error": "No students found"}), 404
        return jsonify(filtered)

    return jsonify(students)


@app.route("/students/<int:id>", methods=["GET"])
def get_student_by_id(id):
    students = read_students()
    student = next((s for s in students if s["id"] == id), None)

    if not student:
        return jsonify({"error": "Student not found"}), 404

    return jsonify(student)


@app.route("/students", methods=["POST"])
def create_student():
    data = request.get_json()

    if not data or not all(k in data for k in ["first_name", "last_name", "age"]):
        return jsonify({"error": "Missing required fields"}), 400

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
def update_student(id):
    data = request.get_json()

    if not data or not all(k in data for k in ["first_name", "last_name", "age"]):
        return jsonify({"error": "Missing required fields"}), 400

    students = read_students()
    student = next((s for s in students if s["id"] == id), None)

    if not student:
        return jsonify({"error": "Student not found"}), 404

    student["first_name"] = data["first_name"]
    student["last_name"] = data["last_name"]
    student["age"] = int(data["age"])

    write_students(students)
    return jsonify(student)


@app.route("/students/<int:id>", methods=["PATCH"])
def patch_student(id):
    data = request.get_json()

    if not data:
        return jsonify({"error": "No data provided"}), 400

    students = read_students()
    student = next((s for s in students if s["id"] == id), None)

    if not student:
        return jsonify({"error": "Student not found"}), 404

    if "first_name" in data:
        student["first_name"] = data["first_name"]
    if "last_name" in data:
        student["last_name"] = data["last_name"]
    if "age" in data:
        student["age"] = int(data["age"])

    write_students(students)
    return jsonify(student)


@app.route("/students/<int:id>", methods=["DELETE"])
def delete_student(id):
    students = read_students()
    student = next((s for s in students if s["id"] == id), None)

    if not student:
        return jsonify({"error": "Student not found"}), 404

    students = [s for s in students if s["id"] != id]
    write_students(students)

    return jsonify({"message": f"Student with id {id} deleted"})


if __name__ == "__main__":
    ensure_csv_exists()
    app.run(host="0.0.0.0", port=8000, debug=True)