Project Overview:

This project allows a POS system with one side for the cashier and one side for the customer.
Data is passed in JSON format.
Tested on various devices, including HiStone, AnyDesk, and Samsung Z Fold.
Issue with Presentation Displays:

Presentation Displays version 1.0.1 by Namit caused corruption and is not working in Release mode.
Revert to Presentation Displays version 1.0.0.
Changes Made:

Custom Java methods have been written in the MainActivity.
Usage Steps:

Paste the provided Java files into app > src > main > java > com.
Update the first line in each Java file to match your project's package name.
Add the display folder to your lib directory.
Important: Remove presentation_displays from pubspec.yaml if you're using it, as it will ruin the APK.
Run flutter clean followed by flutter pub get.
Final Note:

Thank me later if it helps!

![image](https://github.com/user-attachments/assets/164b6b04-d999-4e09-8728-99f2f49d9598)


![image](https://github.com/user-attachments/assets/22d0c957-51f4-4a0f-b946-1936469e38dd)

