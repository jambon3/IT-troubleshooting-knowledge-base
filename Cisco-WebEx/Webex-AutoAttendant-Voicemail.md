# Cisco Webex Calling Auto Attendant and Voicemail Setup

## Objective

Configure a Cisco Webex Calling Auto Attendant to:

- Route calls normally during business hours.
- Play a closed greeting after business hours.
- Send callers to voicemail when the office is closed.

---

## Recommended Call Flow

```text
Main Company Number
        |
        v
Auto Attendant
        |
        +--> Business Hours
        |       |
        |       +--> Service Department
        |       +--> HR Department
        |       +--> Operator
        |
        +--> After Hours
                |
                +--> Play Closed Greeting
                |
                +--> Transfer to Voicemail
```

---

## Option 1: Single Auto Attendant (Recommended)

Most organizations only require one Auto Attendant.

The Auto Attendant can have:

- Business Hours Schedule
- Business Hours Greeting
- After Hours Schedule
- After Hours Greeting
- Different call routing rules for each schedule

### Configuration Steps

1. Sign in to **Webex Control Hub**.
2. Navigate to:

   ```text
   Services → Calling → Features → Auto Attendant
   ```

3. Select the existing company Auto Attendant.
4. Configure the Business Hours schedule:

   ```text
   Monday - Friday
   8:30 AM - 5:00 PM
   ```

5. Configure the After Hours schedule:

   ```text
   All times outside business hours
   ```

6. Configure After Hours routing:

   ```text
   Transfer to Voicemail
   ```

7. Upload or record the After Hours greeting.

---

## Option 2: Separate Business Hours and After Hours Auto Attendants

For more complex environments, create:

### Business Hours Auto Attendant

- Assigned to the main phone number.
- Handles normal office call routing.

### After Hours Auto Attendant

- Plays the closed greeting.
- Routes directly to voicemail.

Example:

```text
Business Hours Auto Attendant
        |
        +--> After Hours Routing
                  |
                  v
        After Hours Auto Attendant
                  |
                  +--> Voicemail
```

---

## Sample After Hours Greeting

> Hello, and thank you for calling Inveris.
>
> We are currently closed.
>
> Our business hours are Monday through Friday, from 8:30 a.m. to 5:00 p.m.
>
> Please leave your name, phone number, and a brief message after the tone, and we will return your call as soon as possible.
>
> Thank you, and have a great day.

---

## Verification Checklist

### Auto Attendant

- [ ] Main phone number assigned
- [ ] Business hours configured
- [ ] After hours configured
- [ ] Correct greetings uploaded
- [ ] Call routing tested

### Voicemail

- [ ] Mailbox created
- [ ] Message waiting enabled
- [ ] Email notifications configured (optional)
- [ ] Greeting recorded
- [ ] Test call completed successfully

---

## Navigation Path

```text
Control Hub
└── Services
    └── Calling
        └── Features
            ├── Auto Attendant
            └── Voicemail
```

---

## Notes

- A single Auto Attendant is usually the simplest solution.
- Separate Auto Attendants are useful when after-hours routing requires different menus or multiple destinations.
- Always test both business-hours and after-hours call flows after making changes.
- Verify voicemail delivery and notification settings before going live.
