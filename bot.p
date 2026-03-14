
import telebot
import random
import time
import threading
from telebot.types import *

TOKEN = "8253626154:AAGWBaV4GXs6klQDYAnwn1NdDcD1b02fbAk"

GROUP_ID = -1003549378995
ADMIN_ID = 8626918981

CHANNEL_LINK = "https://t.me/YOUR_CHANNEL"
BOT_LINK = "https://t.me/@number0022_bot"

bot = telebot.TeleBot(TOKEN)

running = False
speed = 3
otp_count = 0

services = [
"Facebook",
"Telegram",
"Google",
"WhatsApp",
"TikTok",
"Apple",
"1xBet"
]

countries = [

{"name":"Bangladesh","flag":"🇧🇩","code":"#BD","prefix":"+88017","active":True,"service":"Telegram"},
{"name":"Italy","flag":"🇮🇹","code":"#IT","prefix":"+39347","active":True,"service":"Telegram"},
{"name":"USA","flag":"🇺🇸","code":"#US","prefix":"+1201","active":True,"service":"Google"},
{"name":"Pakistan","flag":"🇵🇰","code":"#PK","prefix":"+92345","active":True,"service":"WhatsApp"},
{"name":"Vietnam","flag":"🇻🇳","code":"#VN","prefix":"+8498","active":True,"service":"TikTok"}

]

# -------- NUMBER FORMAT --------
def mask_number(prefix):

    middle = random.randint(1000,9999)
    last = random.randint(100,999)

    return f"{prefix}{middle}****{last}"

# -------- OTP GENERATOR --------
def generate_otp(service):

    if service == "Telegram":
        return random.randint(10000,99999)

    return random.randint(100000,999999)

# -------- GENERATOR LOOP --------
def generator():

    global otp_count

    while True:

        if running:

            active = [c for c in countries if c["active"]]

            if not active:
                time.sleep(2)
                continue

            c = random.choice(active)

            number = mask_number(c["prefix"])
            otp = generate_otp(c["service"])

            text = f"""
{c['flag']} {c['name']} {c['code']} 📱 {c['service']}

{number}

🔑 {otp}
"""

            kb = InlineKeyboardMarkup()

            kb.row(
            InlineKeyboardButton("📢 Main Channel",url=CHANNEL_LINK),
            InlineKeyboardButton("🤖 Number Bot",url=BOT_LINK)
            )

            try:
                bot.send_message(GROUP_ID,text,reply_markup=kb)
                otp_count += 1
            except:
                pass

        time.sleep(speed)

threading.Thread(target=generator,daemon=True).start()

# -------- MAIN MENU --------
def main_menu():

    kb = ReplyKeyboardMarkup(resize_keyboard=True)

    kb.row("⚡ Speed","📊 OTP Stats")
    kb.row("🌍 Countries","🔧 Service Edit")
    kb.row("▶ Start Generator","⏹ Stop Generator")

    return kb

# -------- START --------
@bot.message_handler(commands=['start'])
def start(msg):

    if msg.from_user.id != ADMIN_ID:
        return

    bot.send_message(msg.chat.id,"🤖 OTP BOT READY",reply_markup=main_menu())

# -------- ADMIN PANEL --------
@bot.message_handler(func=lambda message: True)
def panel(message):

    global running,speed,otp_count

    if message.from_user.id != ADMIN_ID:
        return

    if "OTP Stats" in message.text:

        bot.send_message(
        message.chat.id,
        f"📊 OTP Generated : {otp_count}"
        )

    elif "Countries" in message.text:

        keyboard = InlineKeyboardMarkup()

        for i,c in enumerate(countries):

            status = "✅" if c["active"] else "❌"

            keyboard.row(
            InlineKeyboardButton(
            f"{c['flag']} {c['name']} {status}",
            callback_data=f"country_{i}"
            )
            )

        keyboard.row(
        InlineKeyboardButton("⬅ Back",callback_data="back")
        )

        bot.send_message(message.chat.id,"🌍 Country Manager",reply_markup=keyboard)

    elif "Speed" in message.text:

        kb = ReplyKeyboardMarkup(resize_keyboard=True)

        kb.row("1s","2s","3s")
        kb.row("5s","10s","50s")
        kb.row("1m","2m")
        kb.row("⬅ Back")

        bot.send_message(message.chat.id,"⚡ Select Speed",reply_markup=kb)

    elif message.text.endswith("s"):

        speed = int(message.text.replace("s",""))
        bot.send_message(message.chat.id,f"⚡ Speed Set : {speed} sec")

    elif message.text.endswith("m"):

        speed = int(message.text.replace("m",""))*60
        bot.send_message(message.chat.id,f"⚡ Speed Set : {speed} sec")

    elif "Start Generator" in message.text:

        running = True
        bot.send_message(message.chat.id,"✅ Generator Started")

    elif "Stop Generator" in message.text:

        running = False
        bot.send_message(message.chat.id,"🛑 Generator Stopped")

    elif "Back" in message.text:

        bot.send_message(message.chat.id,"🔙 Back",reply_markup=main_menu())

# -------- COUNTRY TOGGLE --------
@bot.callback_query_handler(func=lambda call:True)
def callbacks(call):

    if call.from_user.id != ADMIN_ID:
        return

    if call.data.startswith("country_"):

        i = int(call.data.split("_")[1])

        countries[i]["active"] = not countries[i]["active"]

        status = "ON" if countries[i]["active"] else "OFF"

        bot.answer_callback_query(call.id,f"{countries[i]['name']} {status}")

    elif call.data == "back":

        bot.delete_message(call.message.chat.id,call.message.message_id)

# -------- AUTO DELETE JOIN MESSAGE --------
@bot.message_handler(content_types=['new_chat_members'])
def delete_join_message(message):

    try:
        bot.delete_message(message.chat.id, message.message_id)
    except:
        pass


print("BOT RUNNING...")

bot.infinity_polling()
