# RI Tracing

## Description
RI Tracing is an app used within Raffles Institution for students, 
school personnel and visitors to indicate their presence at 
different locations in the school. The app allows checking in an out of 
specific blocks and rooms within the school (Year 1 to 4 side), 
checking into blocks being automated if location is allowed 
and checking into rooms being manual.

The purpose of the app is to aid in contact tracing. 
Everyone will have to register an account using their RI email. 
One's check in history in the school will only be uploaded to a secure place online 
if the person has contracted the virus, else the data will be store locally 
and only a month of data is kept. After the check in history has been uploaded, 
people who have been in the same place at the same time as the infected person 
will be notified via email.

Icons by Freepik, catkuro, Good Ware, Becris, monkik, ultimatearm, Eucalyp, Prosymbols, smalllikeart, Pause08 from flaticon.com

This app was created by Yunze, Zizhou and Vihaan under the 2020 Swift Accelerator Programme.

## Documentation

### Firestore data structure
Note: anything that's an array is a subcollection, not an array type
```js
{
    history: [
        {
            dateAdded: Timestamp,
            userId: String,
            history: [
                {
                    checkedIn: Timestamp,
                    checkedOut: Timestamp,
                    id: String,
                    target: String
                }, 
                {
                    ...
                    ...
                }
            ]
        }, 
        {
            ...
            ...
        }
    ],
    otp: [
        {
            dateUsed: Timestamp / null,
            isUsed: Bool,
            otp: String
        },
        {
            ...
            ...
        }
    ]
}
```

### Firebase environment config
```js
{
  user_info: { // the info used to send email
    user: String
    password: String
  },
  person_in_charge: { // the info about the person to send OTPs to
    email: String
  }
}
```

### Cloud functions

| Name             | Trigger                              | Description                                                                                                                                                                                                                                                                             | Receives                               | Returns                              |
| ---------------- | ------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------- | ------------------------------------ |
| sendWarningEmail | HTTPS Callable                       | Sends a warning email to the currently logged in user with a list of where and when the user has been in contact with an infected person                                                                                                                                                | An array of intersections (see models) | Nodemailer info about the sent email |
| generateOTPs     | On Firestore "otp" collection update | Generates 20 new OTPs, sends them to person in charge in school, and stores them in Firestore when generating the OTPs, it doesn't take into account if the OTP has been used before, because the chances of collisions are really low given the small number of OTPs we are generating | N.A.                                   | N.A.                                 |

### Data models
Note: Those that are Swift will not show up here because they (should) already have inline documentation.

**Intersection**
- `start: number` The date/unix timestamp of the start of the intersection
- `end: number` The date/unix timestamp of the end of the intersection
- `target: string` The ID of the target, eg "C3-22"

