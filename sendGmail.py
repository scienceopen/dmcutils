#!/usr/bin/env python
"""
send text string (e.g. status) via Gmail STMP

https://docs.python.org/3.6/library/email.examples.html
https://developers.google.com/gmail/api/auth/about-auth
"""
import smtplib
from email.mime.text import MIMEText
from getpass import getpass


def sender(user: str, passw: str, to: list, email_text: str, server: str):
    """
    Should use Oauth.
    """
    with smtplib.SMTP_SSL(server) as s:
        s.login(user, passw)

        msg = MIMEText(email_text)
        msg["Subject"] = "DMC system status update"
        msg["From"] = user
        msg["To"] = ", ".join(to)

        s.sendmail(user, to, msg.as_string())
        s.quit()


if __name__ == "__main__":
    from argparse import ArgumentParser

    p = ArgumentParser()
    p.add_argument("user", help="Gmail username")
    p.add_argument("to", help="email address(es) to send to", nargs="+")
    p.add_argument("-s", "--server", help="SMTP server", default="smtp.gmail.com")
    P = p.parse_args()

    sender(P.user + "@gmail.com", getpass("gmail password"), P.to, "testing", P.server)
