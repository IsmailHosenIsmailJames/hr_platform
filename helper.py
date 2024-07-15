import csv
import json

mapUserData = {}

with open("hr_protal_user_list_7-2024.csv", 'r') as csvFile:
    listOfLines = csv.reader(csvFile)
    for lines in listOfLines:
        mapUserData[lines[0]] = {
            "user_name":lines[1],
            "company_name":lines[2],
            "department_name":lines[3],
            "designation_name":lines[4],
            "date_of_joining":lines[5],
            "cell_phone":lines[6],
            "email":lines[7],
            "job_type_name":lines[8]
        }

with  open("mapUserData.json", 'w') as mapFile:
    json.dump(mapUserData, mapFile, indent=1, sort_keys=True)