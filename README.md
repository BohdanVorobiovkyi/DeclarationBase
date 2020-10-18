# DeclarationBase
App for searching declarations on https://public.nazk.gov.ua/public_api. (iOS 13.0)

- MVC. SearchViewController, FavouriteViewController, WebViewController. 
- Data Manager for work with data localy.
- Network service for internet requests.
- Reachability for checking internet connection before requests.

CoreData > Storing favourite item's list selected by user.
WebKit > Loads PDF declaration in the modal VC.
Cocoa:
ProgressHUD > Activity indicator

For parsing and serializtion fo the jsons with JSONSerialization & Decodable

App Responsibilities: 
- Searching for declarations.
- Displaying search results from the URLrequests.
- Save/remove items to the favourite list. (with star button)
- Adding comments with saving.
- Cancel will clean last results.

Favourite screen:
- Deleting items by swipe.
- Updating comment by didSelect cell.
