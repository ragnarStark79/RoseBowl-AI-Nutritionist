# 🌹 RoseBowl - AI Nutritionist 🥗

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
**Your intelligent cross-platform companion for personalized nutrition advice and effortless meal planning, powered by AI.**

RoseBowl is a mobile application built with **Flutter** designed to be your personal AI nutritionist right in your pocket. It leverages the cutting-edge capabilities of **Gemini AI** for insightful dietary guidance through a conversational interface and utilizes the **Spoonacular API** for generating customized meal plans tailored to your specific needs and preferences. Achieve your health and wellness goals with smart, accessible technology.

---

## ✨ Key Features

* 🤖 **AI Chatbot (Gemini AI):** Engage with an intelligent chatbot for personalized dietary advice, nutritional information, and answers to your food-related questions. Understand your needs through natural conversation.
* 🍽️ **Meal Plan Generator (Spoonacular API):** Instantly generate daily or weekly meal plans based on your dietary requirements (vegan, keto, gluten-free, vegetarian, etc.), calorie targets, and macronutrient goals.
* 🗣️ **Voice Interaction:** Enjoy hands-free operation with integrated **Text-to-Speech (TTS)** for listening to advice/recipes and **Speech-to-Text (STT)** for asking questions using your voice.
* 💾 **Saved Recipes & Plans:** Keep your favorite recipes and generated meal plans saved locally using **SharedPreferences** for quick and easy future access.
* 🎨 **Elegant UI & Dark Mode:** Experience a seamless, responsive, and visually appealing user interface designed for clarity and ease of use, with full support for both light and dark themes.

---

## 💻 Tech Stack

| Technology          | Icon | Purpose                                               |
| :------------------ | :--- | :---------------------------------------------------- |
| **Flutter** | 🐦   | Cross-platform UI development (iOS & Android)         |
| **Gemini AI** | ✨   | AI-powered chatbot for conversational dietary guidance |
| **Spoonacular API** | 🍲   | Fetching meal data, recipe generation, nutrition info |
| **SharedPreferences** | 💾   | Local storage for user preferences & saved data       |
| **TTS & STT Libs** | 🗣️   | Implementing voice interaction and accessibility      |
| **Dart** | 🎯   | Programming language for Flutter                      |

---

## 📸 App Screenshots

| Home Screen                      | AI Chatbot Interface             | Meal Plan Example                |
| :------------------------------- | :------------------------------- | :------------------------------- |
| ![](assets/screenshots/home.png) | ![](assets/screenshots/chatbot.png) | ![](assets/screenshots/mealplan.png) |


---

## 📊 Data Flow Overview

1.  **User Interaction:** Users interact with the Flutter UI via text input or voice commands (STT).
2.  **AI Chat Processing:** Text/Voice input intended for the chatbot is sent to the **Gemini AI** backend. Gemini processes the query and returns a relevant, conversational response.
3.  **Meal Plan Request:** User preferences (diet type, calories, etc.) are sent to the **Spoonacular API** to request meal plan data or specific recipes.
4.  **Data Display:** The app receives responses from Gemini AI and Spoonacular API, formats the data, and displays it to the user (text, meal cards, etc.). TTS can be used to read out information.
5.  **Local Storage:** User settings, preferences, and explicitly saved recipes/plans are stored locally using **SharedPreferences** for persistence across app sessions.

*(Optional: Consider creating visual diagrams (e.g., using Mermaid syntax if GitHub renders it, or linking image files) for a more detailed representation if needed)*

---

## 🌟 Benefits & Use Cases

* 🎯 **Personalized Nutrition:** Get dietary advice and meal plans tailored specifically to *your* goals, allergies, and preferences.
* 🍎 **Promote Healthier Habits:** Make more informed food choices with accessible nutritional information and guidance.
* ⏱️ **Effortless Meal Planning:** Save significant time and reduce the mental load of deciding what to eat.
* ✅ **Diverse Diet Support:** Whether you're vegan, gluten-free, vegetarian, keto, or follow another specific diet, RoseBowl can help.
* 🚶 **Guidance On-the-Go:** Access nutritional support anytime, anywhere, especially convenient with hands-free voice commands.

---

## 🚀 Future Scope

RoseBowl aims to evolve into a more holistic health and wellness assistant. Potential future enhancements include:

* ⌚ **Wearable Integration:** Connect with fitness trackers (e.g., Google Fit, Apple HealthKit) to incorporate real-time activity and health metrics for even more personalized recommendations.
* 📊 **Calorie & Macro Tracking:** Add features for users to log their food intake and track daily/weekly calorie and macronutrient consumption against their goals.
* 🧠 **Advanced AI Personalization:** Fine-tune the AI model based on user feedback and history for deeper personalization and proactive health suggestions.
* 🤝 **Community Features:** Introduce options for users to share their favorite recipes, meal plans, and wellness tips within the app community.
* 🛒 **Grocery List Generation:** Automatically create shopping lists based on generated meal plans.

---

## 🛠️ Getting Started

Follow these steps to set up and run the RoseBowl project locally:

1.  **Prerequisites:**
    * Ensure you have **Flutter** installed. If not, follow the [official Flutter installation guide](https://docs.flutter.dev/get-started/install).
    * An editor like VS Code or Android Studio.

2.  **Clone the Repository:**
    ```bash
    git clone [https://github.com/ragnarStark79/RoseBowl-AI-Nutritionist.git](https://github.com/ragnarStark79/RoseBowl-AI-Nutritionist.git)
    cd RoseBowl-AI-Nutritionist
    ```

3.  **Set Up Environment Variables:**
    * Create a file named `.env` in the root directory of the project.
    * Add your API keys to this file:
        ```dotenv
        GEMINI_API_KEY=YOUR_GEMINI_API_KEY_HERE
        SPOONACULAR_API_KEY=YOUR_SPOONACULAR_API_KEY_HERE
        ```
    * *Where to get keys:*
        * **Gemini AI Key:** Obtain from [Google AI Studio](https://aistudio.google.com/).
        * **Spoonacular API Key:** Obtain from the [Spoonacular API website](https://spoonacular.com/food-api).

4.  **Install Dependencies:**
    Run the following command in your terminal from the project root:
    ```bash
    flutter pub get
    ```

5.  **Run the App:**
    * Ensure you have an emulator running or a physical device connected.
    * Run the app using:
    ```bash
    flutter run
    ```

---

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**!

1.  **Fork** the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a **Pull Request**

Please ensure your code adheres to the project's coding style and includes relevant tests if applicable.

---

## 📄 License

This project is distributed under the MIT License. See the `LICENSE` file for more information.

```markdown
MIT License

Copyright (c) [2025] [Ragnar Stark]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
