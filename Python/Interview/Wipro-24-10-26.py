"""
Get Pairs from the list that adds upto target
"""
list_of_num = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
Target = 12

seen = set()

for num in list_of_num:
    complement = Target - num

    if complement in seen:
        print(complement, num)

    seen.add(num)
