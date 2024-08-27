#1. Print function
print('hello lambda course')

#2. Variable
response = 'hello'
print(response)

#3. Data Type - Dictionary
response = {1: 'Rahul', 2: 'John', 3: 'Joy'}
print(response[3])

#4. Data Type - Nested Dictionary
response = {1:'Python', 2:{'books': 'arch' , 'aws':'Lambda'}}
print(response[2]['aws'])

#5. Dictionary - Boto3
response = {
    'Buckets': [
        {
            'Name': 'string',
            'CreationDate': 25
        },
    ],
    'Owner': {
        'DisplayName': 'string',
        'ID': 'string'
    }
}
print(response['Buckets'])

#6. Data Type - List
list = [1, 4, 'For', 6, 'Anisha']
print(list[1])

#7. Data Type - Nested List
nestedList = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
print(nestedList[2][2])

#8. Dictionary and List
response = {
    'Buckets': [
        {
            'Name': 'bucket1',
            'CreationDate': 25
        },
        {
            'Name': 'bucket2',
            'CreationDate': 25
        },
    ],
    'Owner': {
        'DisplayName': 'string',
        'ID': 'string'
    }
}

print(response['Buckets'][1])

#9. Data Type determination
response = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
print(type(response))

#10. Function
def evenOdd(x):
    if (x % 2 == 0):
        print("even")
    else:
        print("odd")
print(evenOdd(4))



