class Employee:
    def __init__(self,id,name):
        self.id = 1 + id
        self.name = name
    def creator(self):
        return f"id => {self.id} \nName = {self.name}"

emp = Employee(1, "coder")

emp.creator()

del emp.id

try:
    print(emp.creator())
except AttributeError:
    print("Employee ID not found")

# create iterator

class Squares:
    """
    An iterator that generates square numbers up to a given limit (inclusive).
    Example: Squares(5) -> 1, 4, 9, 16, 25
    """
    def __init__(self, num: int):
        self.current = 1
        self.limit = num
        if type(num) != int:
            print('\nKindly use Only Integers !\n')
            raise ValueError

    def __iter__(self):
        return self

    def __next__(self):
        if self.current <= self.limit:
            value = self.current ** 2
            self.current += 1
            return value
        raise StopIteration

print("Square numbers:")
for sq in Squares(7):
    print(sq)

# use generator for same thing

def Gen_Square(num:int):
    i = 1
    print("This is Generator !")
    while i <= num:
        yield i*i
        i += 1

for i in Gen_Square(5):
    print(i)