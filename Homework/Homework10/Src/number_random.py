import random

def guess_number():
    secret_number = random.randint(1, 100)
    attempts = 5

    print("Я загадав число від 1 до 100.")
    print("Спробуйте його вгадати. У вас є 5 спроб.")

    for attempt in range(1, attempts + 1):
        try:
            guess = int(input(f"Спроба {attempt}/5. Введіть число: "))
        except ValueError:
            print("Будь ласка, введіть ціле число.")
            continue

        if guess == secret_number:
            print("Вітаємо! Ви вгадали правильне число")
            return
        elif guess > secret_number:
            print("Занадто високо")
        else:
            print("Занадто низько")

    print(f"Вибачте, у вас закінчилися спроби. Правильний номер був {secret_number}")

def main():
    guess_number()

if __name__ == "__main__":
    main()