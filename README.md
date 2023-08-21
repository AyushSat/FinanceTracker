# FinanceTracker

This application serves as a helper for any user to keep track of their spendings month by month, categorize transactions, and view important data about their spending patterns. All data can either be synced to the cloud securely or stored on device for maximum privacy.

<div style="display: flex; justify-content: space-between;">
    <img src="https://github.com/AyushSat/FinanceTracker/assets/18633636/e82e5eca-744e-46b0-83ad-2d06bace3494" alt="IMG_0861" width="200" height: auto;">
    <img src="https://github.com/AyushSat/FinanceTracker/assets/18633636/79cf6c76-aa96-41bc-b538-812bb49f3790" alt="IMG_0862" width="200" height: auto;">
</div>

<br>

On the **Home** page, users can log transactions, which are made up of a name, a date, a cost, and a category. As transactions build, users will be able to see graphs and charts representing their monthly spending over time, overall breakdowns in categorized spending, and the current month spending by category. 
<br>
<div style="display: flex; justify-content: space-between;">
    <img src="https://github.com/AyushSat/FinanceTracker/assets/18633636/9be882e2-bb8e-4541-be0e-cedcd42d1fee" alt="IMG_0864" width="200" height: auto;">
    <img src="https://github.com/AyushSat/FinanceTracker/assets/18633636/a6c8cbf8-5e1c-4238-a962-4fbb069c3df8" alt="IMG_0865" width="200" height: auto;">
</div>
<br>
On the **History** page, users can view a full list of all the transactions they have ever made, sorted by the month starting at most recent. At a glance, each transaction is displayed by name and cost for identification ease. To view more information, namely the category and date, users can tap any transaction and view a popup with more information. If any transaction was made in error, users can swipe left on any transaction to delete.
<br>
<div style="display: flex; justify-content: space-between;">
    <img src="https://github.com/AyushSat/FinanceTracker/assets/18633636/50b6f567-28d0-4c27-a942-3523a6312533" alt="IMG_0867" width="200" height: auto;">
    <img src="https://github.com/AyushSat/FinanceTracker/assets/18633636/f7de6476-e26c-43d3-a3d5-7c38892dc7f7" alt="IMG_0868" width="200" height: auto;">
</div>
<br>
On the **Settings** page, users can sync their data with the cloud. If they have not published their data to the cloud, the user can enter a password and publish that data to the cloud. If the user switches phones or redownloads the app, they can put their old password in and pull in any existing data. This functionality can also be used to utilize different accounts to track different sets of transactions. Once a password is set, any changes to the transactions, categories, or limits are automatically synced. All password information is encrypted on device using CryptoKit and the SHA256 algorithm.  Cloud servers never store the password in plaintext for maximum security.
<br>
<br>
Here is a live demo of the Cloud sync functionality:
<br>
<br>

https://github.com/AyushSat/FinanceTracker/assets/18633636/f241f9e6-b019-45c0-af5a-de3b46304761

<br>
Users can also set a monthly spending limit, which will be used on the home page to inform users about how much money they have left for the current month. They can also add specific categories tailored to their use cases, as well as view the current categories they have. If any are unused, the user can swipe left to delete a category, marking any transactions that used to be in the deleted category as "Other".
