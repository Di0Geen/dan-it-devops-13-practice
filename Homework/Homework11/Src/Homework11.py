class Alphabet:
    def __init__(self, lang, letters):
        self.lang = lang
        self.letters = list(letters)

    def print(self):
        print(" ".join(self.letters))

    def letters_num(self):
        return len(self.letters)

class EngAlphabet(Alphabet):
    _letters_num = 26

    def __init__(self):
        super().__init__("En", "ABCDEFGHIJKLMNOPQRSTUVWXYZ")

    def s_en_letter(self, letter):
        return letter.upper() in self.letters

    def letters_num(self):
        return EngAlphabet._letters_num
    @staticmethod
    def example():
        return "The screen on my phone is broken."

eng_alphabet = EngAlphabet()

eng_alphabet.print()

print("Кількість літер:", eng_alphabet.letters_num())

print("Чи є 'F' в англійському алфавіті?", eng_alphabet.s_en_letter('F'))
print("Чи є 'Щ' в англійському алфавіті?", eng_alphabet.s_en_letter('Щ'))

print("Приклад тексту:", EngAlphabet.example())