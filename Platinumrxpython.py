# 1) Given number of minutes, convert it into human readable form.
# Example :
# 130 becomes “2 hrs 10 minutes”
# 110 becomes “1hr 50minutes”
minutes = int(input("Enter minutes: "))

hours = minutes // 60
remaining_minutes = minutes % 60

# Formatting output
if hours > 0 and remaining_minutes > 0:
    print(f"{hours} hr{'s' if hours > 1 else ''} {remaining_minutes} minutes")
elif hours > 0:
    print(f"{hours} hr{'s' if hours > 1 else ''}")
else:
    print(f"{remaining_minutes} minutes")





# 2) You are given a string, remove all the duplicates and print the unique string.Use loop in the python.


string = input("Enter a string: ")

result = ""

for char in string:
    if char not in result:
        result += char

print("Unique string:", result)