// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'My Furniture Store';

  @override
  String get navProducts => 'PRODUCTS';

  @override
  String get navRoomDesign => 'ROOM DESIGN';

  @override
  String get navAbout => 'ABOUT';

  @override
  String get navContact => 'CONTACT';

  @override
  String get accountInfo => 'ACCOUNT INFORMATION';

  @override
  String get yourAccount => 'Your account';

  @override
  String get profileMenuTitle => 'Account';

  @override
  String get addressList => 'Address list';

  @override
  String get deliveryHistory => 'Delivery history';

  @override
  String get adminPage => 'Go to admin page';

  @override
  String get logout => 'Log out';

  @override
  String get loggedOut => 'Logged out';

  @override
  String get accountOf => 'Account';

  @override
  String get loginRegister => 'Log in / Register';

  @override
  String get search => 'Search';

  @override
  String get cart => 'Cart';

  @override
  String get language => 'Language';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'English';

  @override
  String helloUser(String name) {
    return 'Hello, $name';
  }

  @override
  String get footerDescription =>
      'From design and manufacturing to logistics and after-sales, we are your one-stop furniture partner in Vietnam.';

  @override
  String get exploreMore => 'EXPLORE MORE';

  @override
  String get home => 'HOME';

  @override
  String get contactUs => 'CONTACT US';

  @override
  String get companyAddress =>
      'Street P, Group 4, Song Vinh Commune\nTan Phuoc Ward, Phu My Town, Ba Ria\nVung Tau Province';

  @override
  String homeLoadError(Object error) {
    return 'Error: $error';
  }

  @override
  String get noProducts => 'No products available.';

  @override
  String get categories => 'Categories';

  @override
  String get bestSellingProducts => 'Best-selling products';

  @override
  String get viewMore => 'View more';

  @override
  String soldCount(int count) {
    return 'Sold $count';
  }

  @override
  String get loginTitle => 'Log in or register';

  @override
  String get loginIntro =>
      'Enter your email to log in with a password or register quickly. When registering, the system will email you a link to set your password.';

  @override
  String get emailAddress => 'EMAIL ADDRESS';

  @override
  String get emailField => 'Email address';

  @override
  String get loginWithPassword => 'LOG IN WITH PASSWORD';

  @override
  String get quickRegister => 'QUICK REGISTRATION';

  @override
  String get secureLinkHint =>
      'No password will be sent by email. You will set your own password through a secure link.';

  @override
  String get backHome => 'Back to home';

  @override
  String get invalidEmail => 'Please enter a valid email address.';

  @override
  String get checkEmailTitle => 'Check your email';

  @override
  String get quickRegisterDialogBody =>
      'A password setup link has been sent to your email.\n\nThe link can only be used once and expires after 30 minutes. If you cannot find the email, please check your Spam/Junk folder.';

  @override
  String get understood => 'GOT IT';

  @override
  String get passwordLoginTitle => 'Log in with password';

  @override
  String get passwordLoginWelcome =>
      'Welcome back to My Furniture Store. Enter your email or username and password to access your account.';

  @override
  String get emailOrUsername => 'EMAIL OR USERNAME';

  @override
  String get emailOrUsernameField => 'Email or username';

  @override
  String get emailOrUsernameHint => 'Enter your email or username...';

  @override
  String get password => 'PASSWORD';

  @override
  String get passwordField => 'Password';

  @override
  String get passwordHint => 'Enter your password...';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get login => 'LOG IN';

  @override
  String loginSuccess(String name) {
    return 'Login successful! Welcome, $name';
  }

  @override
  String get incompleteLogin =>
      'Please check and complete all login information!';

  @override
  String requiredField(String field) {
    return 'Please enter $field!';
  }

  @override
  String minLengthField(String field, int count) {
    return '$field must contain at least $count characters!';
  }

  @override
  String get backToLoginOptions => 'Back to login options';

  @override
  String get allProductsTitle => 'All My Furniture Home products';

  @override
  String get sortFeatured => 'Featured products';

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortPriceLowHigh => 'Price: Low to High';

  @override
  String get sortPriceHighLow => 'Price: High to Low';

  @override
  String get category => 'Category';

  @override
  String get colors => 'Colors';

  @override
  String get sizes => 'Sizes';

  @override
  String get filters => 'FILTERS';

  @override
  String filtersActive(int count) {
    return 'FILTERS ($count)';
  }

  @override
  String get detailedFilters => 'Detailed filters';

  @override
  String get closeFilters => 'Close filters';

  @override
  String get priceRange => 'Price range';

  @override
  String get clearFilters => 'CLEAR FILTERS';

  @override
  String get productPrice => 'PRODUCT PRICE';

  @override
  String abovePrice(String price) {
    return 'Above $price';
  }

  @override
  String belowPrice(String price) {
    return 'Below $price';
  }

  @override
  String get allSubcategories => 'All subcategories';

  @override
  String get allCategories => 'All categories';

  @override
  String get allPriceRanges => 'All price ranges';

  @override
  String get allColors => 'All colors';

  @override
  String get allSizes => 'All sizes';

  @override
  String get noMatchingProducts => 'No matching products found.';

  @override
  String get productNotFound => 'Product not found!';

  @override
  String inStock(int count) {
    return 'In stock: $count items';
  }

  @override
  String get temporarilyOutOfStock => 'Out of stock (temporarily unavailable)';

  @override
  String get productDescription => 'Product description';

  @override
  String get noProductDescription =>
      'No description is available for this product.';

  @override
  String get dimensionsLabel => 'Dimensions:';

  @override
  String get materialLabel => 'Material:';

  @override
  String get outOfStock => 'OUT OF STOCK';

  @override
  String get addToCart => 'ADD TO CART';

  @override
  String get buyNow => 'BUY NOW';

  @override
  String get tryInYourRoom => 'TRY IT IN YOUR ROOM';

  @override
  String get frequentlyBoughtTogether => 'FREQUENTLY BOUGHT TOGETHER';

  @override
  String get relatedProducts => 'RELATED PRODUCTS';

  @override
  String get productReviews => 'PRODUCT REVIEWS';

  @override
  String averageRating(int count) {
    return 'AVERAGE RATING\n($count reviews)';
  }

  @override
  String reviewDistribution(String percent, int count) {
    return '$percent% | $count reviews';
  }

  @override
  String get reviewDeliveredOnly =>
      'You can only review products from paid and delivered orders.';

  @override
  String get viewOrderHistory => 'VIEW ORDER HISTORY';

  @override
  String get all => 'All';

  @override
  String get noMatchingReviews => 'No reviews match the selected filter.';

  @override
  String get noWrittenReview => 'No written comment.';

  @override
  String get storeReply => 'Store reply';

  @override
  String cartItemCount(int count) {
    return 'Cart ($count)';
  }

  @override
  String get yourCart => 'Your cart';

  @override
  String get remove => 'Remove';

  @override
  String get emptyCart => 'Your cart is empty';

  @override
  String get continueShopping => 'CONTINUE SHOPPING';

  @override
  String get orderInformation => 'Order summary';

  @override
  String get total => 'Total:';

  @override
  String get checkout => 'CHECKOUT';

  @override
  String get continueBuying => 'Continue shopping';

  @override
  String get voucherWallet => 'Voucher Wallet';

  @override
  String currentOrder(String amount) {
    return 'Current order: $amount';
  }

  @override
  String get noAvailableVouchers =>
      'There are currently no available vouchers in your wallet.';

  @override
  String discountPercent(String value) {
    return 'SAVE $value%';
  }

  @override
  String discountAmount(String amount) {
    return 'SAVE $amount';
  }

  @override
  String expiresOn(String date) {
    return 'Expires: $date';
  }

  @override
  String voucherUsage(int used, int limit) {
    return 'Used: $used/$limit';
  }

  @override
  String spendMoreToUse(String amount) {
    return 'Spend $amount more to use';
  }

  @override
  String get apply => 'APPLY';

  @override
  String get morningSlot => 'Morning (08:00 - 12:00)';

  @override
  String get afternoonSlot => 'Afternoon (13:00 - 17:00)';

  @override
  String get eveningSlot => 'Evening (18:00 - 20:00)';

  @override
  String get enterOrSelectVoucher => 'Please enter or select a promotion code.';

  @override
  String get loginBeforeOrdering => 'Please log in before placing an order.';

  @override
  String get checkCheckoutInformation =>
      'Please check your name, phone number, and email before placing the order!';

  @override
  String get cartIsEmpty => 'Your cart is empty!';

  @override
  String get paymentMaintenance =>
      'MoMo and QR are under maintenance. Please choose bank transfer, POS, or VNPay.';

  @override
  String get missingVnPayUrl =>
      'The backend did not return a VNPay payment URL.';

  @override
  String get cannotOpenVnPay => 'Unable to open the VNPay payment gateway.';

  @override
  String createOrderError(Object error) {
    return 'Unable to create order: $error';
  }

  @override
  String get vnPaySuccess => 'VNPay payment successful';

  @override
  String get vnPayFailed => 'VNPay payment failed';

  @override
  String paidOrderMessage(String orderId) {
    return 'Order #$orderId has been paid and is waiting for store confirmation.';
  }

  @override
  String failedOrderMessage(String orderId) {
    return 'The transaction failed or was cancelled. Order #$orderId was cancelled and its stock was restored.';
  }

  @override
  String get orderRecorded => 'Order recorded!';

  @override
  String get orderSuccess => 'Order placed successfully!';

  @override
  String get bankTransferInstructions =>
      'Your order has been recorded successfully.\nPlease complete the bank transfer using the displayed information so the order can be approved for delivery.';

  @override
  String orderThankYou(String name) {
    return 'Thank you for your order, $name.\nYour POS payment is complete and the order is being processed.';
  }

  @override
  String get loginBenefit =>
      'Log in for easier shopping and more special offers';

  @override
  String get loginAction => 'Log in';

  @override
  String get shippingInformation => 'Shipping information';

  @override
  String get enterFullName => 'Enter full name (*)';

  @override
  String get fullName => 'Full name';

  @override
  String get enterPhone => 'Enter phone number (*)';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get invalidPhone =>
      'The phone number must contain 10 digits and start with 0!';

  @override
  String get enterOrderEmail => 'Enter email (* for order notifications)';

  @override
  String get country => 'Country';

  @override
  String get vietnam => 'Vietnam';

  @override
  String get streetAddress => 'Street address (*)';

  @override
  String get address => 'Address';

  @override
  String get regionAutoFill => 'Province/City, District, Ward (Auto-filled)';

  @override
  String get selectDeliveryArea => 'Please select a delivery area';

  @override
  String get deliveryAssemblyService => 'Home Delivery & Assembly Service';

  @override
  String deliveryEstimate(String distance, String fee) {
    return 'Estimated delivery distance: $distance km\nDistance-based shipping fee: $fee';
  }

  @override
  String get selectDeliveryTime => 'Select a delivery time slot:';

  @override
  String get assemblySupport => 'Request in-home furniture assembly support';

  @override
  String fixedAssemblyFee(String fee) {
    return 'Fixed assembly service fee: +$fee';
  }

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get bankTransferPayment => 'Payment by bank transfer';

  @override
  String get accountName =>
      'Account name: Savimex Economic Cooperation and Import Export JSC';

  @override
  String get accountNumber => 'Account number: 0071001303667';

  @override
  String get bankName => 'Bank: Vietcombank - HCMC Branch';

  @override
  String get transferContent =>
      'Transfer content: Customer name + phone number';

  @override
  String get posPayment => 'Card payment on delivery (POS)';

  @override
  String get vnPayPayment =>
      'Online payment via VNPay (ATM/Visa/MasterCard/JCB/QR Pay/Internet Banking)';

  @override
  String get momoPayment => 'Online payment via MoMo wallet';

  @override
  String get qrTransfer => 'QR bank transfer - VCB';

  @override
  String get orderNote => 'Order note';

  @override
  String get orderNoteHint => 'Enter a note for your order...';

  @override
  String get emptyCartShort => 'Cart is empty';

  @override
  String get promotionApplied => 'Promotion applied:';

  @override
  String get promotionCode => 'Promotion code';

  @override
  String get openVoucherWallet => 'Open Voucher Wallet & Select an Offer';

  @override
  String get enterPromotionCode => 'Enter promotion code';

  @override
  String get orderSummary => 'Order summary';

  @override
  String get subtotal => 'Subtotal';

  @override
  String shippingFeeDistance(String distance) {
    return 'Shipping fee$distance:';
  }

  @override
  String get assemblyServiceFee => 'Assembly service fee:';

  @override
  String get discount => 'Discount';

  @override
  String get totalPayment => 'Total payment';

  @override
  String get placeOrder => 'Place order';

  @override
  String get account => 'ACCOUNT';

  @override
  String get accountDetails => 'ACCOUNT INFORMATION';

  @override
  String get profileInformation => 'Account information';

  @override
  String get myVouchers => 'My vouchers (Offer wallet)';

  @override
  String get helpCenter => 'Q&A & Help Center';

  @override
  String get lastName => 'Last name and middle name';

  @override
  String get firstName => 'First name';

  @override
  String get gender => 'Gender';

  @override
  String get female => 'Female';

  @override
  String get male => 'Male';

  @override
  String get dateOfBirth => 'Date of birth';

  @override
  String get update => 'UPDATE';

  @override
  String get profileUpdated => 'Profile updated successfully!';

  @override
  String get loginAgain => 'Please log in again.';

  @override
  String get addressBook => 'ADDRESS LIST';

  @override
  String get addAddress => 'Add address';

  @override
  String get editAddress => 'Edit address';

  @override
  String get cannotLoadAddresses => 'Unable to load the address list.';

  @override
  String get noAddresses => 'No addresses have been added yet.';

  @override
  String get defaultAddress => 'Default';

  @override
  String get recipient => 'Recipient';

  @override
  String get fullAddress => 'Full address';

  @override
  String get addressLabel => 'Address label';

  @override
  String get addressLabelHome => 'Home';

  @override
  String get addressLabelCompany => 'Company';

  @override
  String get addressLabelOther => 'Other';

  @override
  String get addressSearchHint =>
      'Enter at least 3 characters to find an address';

  @override
  String get makeDefault => 'Set as default';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get loginToViewOrders =>
      'Please log in to view your delivery history.';

  @override
  String get deliveryHistoryTitle => 'DELIVERY HISTORY';

  @override
  String get awaitingPayment => 'Awaiting payment';

  @override
  String get awaitingConfirmation => 'Awaiting confirmation';

  @override
  String get awaitingDelivery => 'Awaiting delivery';

  @override
  String get shipping => 'Shipping';

  @override
  String get delivered => 'Delivered';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get returnedRefunded => 'Returned/Refunded';

  @override
  String get returned => 'Returned';

  @override
  String get paid => 'Paid';

  @override
  String get noOrdersForStatus => 'No orders were found with this status.';

  @override
  String loadOrdersError(Object error) {
    return 'Unable to load orders: $error';
  }

  @override
  String orderCode(String code) {
    return 'Order code: $code';
  }

  @override
  String orderDate(String date) {
    return 'Order date: $date';
  }

  @override
  String variantDetails(String color, String size) {
    return 'Variant: $color / $size';
  }

  @override
  String quantity(int count) {
    return 'Quantity: $count';
  }

  @override
  String get reviewed => 'Reviewed';

  @override
  String get review => 'Review';

  @override
  String paymentLabel(String method) {
    return 'Payment: $method';
  }

  @override
  String get totalAmount => 'Total:';

  @override
  String reviewProductTitle(String product) {
    return 'Review: $product';
  }

  @override
  String get verifiedPurchaseDelivered =>
      'Payment and successful delivery have been verified.';

  @override
  String get satisfactionLevel => 'Satisfaction level';

  @override
  String get optionalComment => 'Comment (optional)';

  @override
  String get reviewHint => 'Share your experience with this product...';

  @override
  String get reviewSuccess => 'Review submitted successfully.';

  @override
  String get submitReview => 'Submit review';

  @override
  String voucherCopiedMessage(String code) {
    return 'Voucher code [$code] was copied and saved!';
  }

  @override
  String get allAvailableVouchers => '🌟 All available';

  @override
  String get expiringSoonVouchers => '🔥 Expiring soon (< 7 days)';

  @override
  String get newVouchers => '✨ Newly issued';

  @override
  String get myVoucherWalletTitle => 'MY VOUCHERS / OFFER WALLET';

  @override
  String get voucherWalletDescription =>
      'Manage, collect, and use promotional codes for your furniture orders.';

  @override
  String get noExpiringVouchers =>
      'You have no vouchers expiring within the next 7 days.';

  @override
  String get noNewVouchers => 'There are no vouchers newly issued this week.';

  @override
  String get discountBadge => 'DISCOUNT';

  @override
  String expiryDate(String date) {
    return 'Expires: $date';
  }

  @override
  String voucherDescriptionMinOrder(String description, String amount) {
    return '$description - Minimum order $amount';
  }

  @override
  String orderFrom(String amount) {
    return 'Orders from $amount';
  }

  @override
  String maxDiscount(String amount) {
    return 'Maximum discount $amount';
  }

  @override
  String voucherUsedPercent(String percent) {
    return '🔥 Used: $percent%';
  }

  @override
  String remainingUses(int count) {
    return '$count uses left';
  }

  @override
  String get copied => 'Copied';

  @override
  String get copyCode => 'Copy code';

  @override
  String get useNow => 'Use now';

  @override
  String get loginToAsk => 'Please log in to submit a question!';

  @override
  String get questionSubmitted =>
      '🎉 Your question was submitted! You will receive an email as soon as the admin replies.';

  @override
  String genericError(Object error) {
    return 'Error: $error';
  }

  @override
  String get qaCenterTitle => 'Q&A & HELP CENTER';

  @override
  String get qaCenterDescription =>
      'Send your questions to the administration team. The system will email you the details as soon as an admin replies.';

  @override
  String get newQuestionTab => '❓ Ask a New Question';

  @override
  String questionHistoryTab(int count) {
    return '📜 Question History ($count)';
  }

  @override
  String get chooseSupportTopic => '1. Choose a Support Topic';

  @override
  String get questionContent => '2. Question Details';

  @override
  String get questionContentField => 'Question details';

  @override
  String get questionHint =>
      'Example: I need this sofa in a custom size. Do you offer made-to-order sizing, and how much does it cost?';

  @override
  String get sending => 'Sending...';

  @override
  String get sendQuestionToAdmin => 'Send Question to Admin';

  @override
  String get noQuestions =>
      'You have not submitted any questions or support requests.';

  @override
  String get answeredEmailed => '✅ Answered (Email sent)';

  @override
  String get awaitingReply => '⏳ Awaiting reply';

  @override
  String sentAt(String time) {
    return 'Sent at: $time';
  }

  @override
  String get yourQuestion => '❓ Your question:';

  @override
  String get officialAdminReply => '💡 Official reply from Admin:';

  @override
  String answeredAt(String time) {
    return 'At: $time';
  }

  @override
  String get topicProductAdvice => 'Product and material advice';

  @override
  String get topicPolicies => 'Warranty, returns, and shipping policies';

  @override
  String get topicCustomDesign => 'Custom furniture and design consultation';

  @override
  String get topicFeedback => 'Service feedback';

  @override
  String get mySpace => 'My space';

  @override
  String get waitForAiGeneration =>
      'Please wait for the current AI generation to finish.';

  @override
  String get roomImageTooLarge => 'The room image must not exceed 10 MB.';

  @override
  String get roomUploaded =>
      'Room image uploaded. You can adjust it manually or use AI.';

  @override
  String get defaultVariant => 'Default';

  @override
  String chooseProductVariant(String product) {
    return 'Choose a variant of $product';
  }

  @override
  String stockRemaining(int count) {
    return '$count items remaining';
  }

  @override
  String get uploadRoomFirst => 'Please upload a room image first.';

  @override
  String get backgroundRemovedAdded =>
      'The background was removed and the product was added to the room.';

  @override
  String get chooseProduct => 'Choose a product';

  @override
  String get chooseRoomAndProductImages =>
      'Please select both a room image and a product image.';

  @override
  String get aiServiceNotReady => 'The AI service is not ready.';

  @override
  String get generateNewAiImageTitle => 'Generate a new image with AI?';

  @override
  String get aiGenerateConfirmAuto =>
      'AI will receive exactly two images: the room and the product variant. AI will choose a suitable position. Each generation may incur API charges.';

  @override
  String get aiGenerateConfirmPrompt =>
      'AI will receive exactly two images: the room and the product variant. AI will prioritize the position you described. Each generation may incur API charges.';

  @override
  String get generateImage => 'Generate image';

  @override
  String get aiImageLoadedFromCache => 'AI image loaded from cache.';

  @override
  String get aiImageGenerated =>
      'AI generated a new image from the two inputs.';

  @override
  String get designSaved => 'Design saved.';

  @override
  String get cannotCreateResultImage => 'Unable to create the result image.';

  @override
  String get visualizationDownloaded => 'Visualization image downloaded.';

  @override
  String get roomVisualizerTitle => 'Room visualizer';

  @override
  String get uploadRoomImage => 'Upload room image';

  @override
  String get changeRoomImage => 'Change room image';

  @override
  String get saveDesign => 'Save design';

  @override
  String get exportImage => 'Export image';

  @override
  String get uploadYourRoom => 'Upload a photo of your room';

  @override
  String get roomImageRequirements => 'Supports JPG, PNG, WEBP; maximum 10 MB.';

  @override
  String get uploadingImage => 'Uploading image…';

  @override
  String get chooseRoomImage => 'Choose room image';

  @override
  String get manualAdjustment => 'Manual adjustment';

  @override
  String get aiGenerateImage => 'AI generation';

  @override
  String get chooseProductManualHint =>
      'Choose a product to start adjusting manually';

  @override
  String get chooseProductAiHint =>
      'Choose a product, then ask AI to generate a new image';

  @override
  String get aiGeneratingNewImage => 'AI is generating a new image…';

  @override
  String get analyzingSpace => 'Analyzing the space…';

  @override
  String get designLayer => 'Design';

  @override
  String get floorWallLayer => 'Floor / walls';

  @override
  String get depthLayer => 'Depth';

  @override
  String get floorMaskLayer => 'Floor mask';

  @override
  String get wallMaskLayer => 'Wall mask';

  @override
  String get productsTab => 'Products';

  @override
  String get adjustmentsTab => 'Adjustments';

  @override
  String get selectProductOnCanvas => 'Select a product on the canvas.';

  @override
  String get placementSurface => 'Placement surface';

  @override
  String get freePlacement => 'Free';

  @override
  String get floorSurface => 'Floor';

  @override
  String get leftWall => 'Left wall';

  @override
  String get rightWall => 'Right wall';

  @override
  String get sizeControl => 'Size';

  @override
  String get flatRotation => 'Flat rotation';

  @override
  String get perspectiveRotation => 'Left / right perspective rotation';

  @override
  String get brightness => 'Brightness';

  @override
  String get shadowIntensity => 'Shadow intensity';

  @override
  String get flipProduct => 'Flip product horizontally';

  @override
  String get duplicate => 'Duplicate';

  @override
  String get delete => 'Delete';

  @override
  String get aiFromTwoImages => 'AI image from two inputs';

  @override
  String get aiFromTwoImagesDescription =>
      'AI directly receives the room and product-variant images, then generates a new visualized scene.';

  @override
  String get roomImage => 'Room image';

  @override
  String get uploadedImage => 'Your uploaded image';

  @override
  String get noProductSelected => 'No product selected';

  @override
  String get chooseVariantBelow => 'Choose a variant below';

  @override
  String get chooseProductColor => 'Choose product and color';

  @override
  String get changeProductColor => 'Change product / color';

  @override
  String get desiredPlacementOptional => 'Desired position (optional)';

  @override
  String get placementPromptHint =>
      'Example: Place the table by the left window, facing the center of the room.';

  @override
  String get placementPromptHelp =>
      'Describe only the position, rotation, or placement area. If left blank, AI will arrange it automatically.';

  @override
  String get aiServiceUnavailable => 'Unable to connect to the AI service.';

  @override
  String get aiGenerating => 'AI is generating an image…';

  @override
  String get generateNewImageWithAi => 'Generate a new image with AI';

  @override
  String get regenerateImage => 'Generate another image';

  @override
  String get downloadCurrentAiImage => 'Download current AI image';

  @override
  String get aiImageDisclaimer =>
      'AI images are for reference only. Each generation may incur API charges; verify the actual color and dimensions before purchasing.';

  @override
  String get chatPromptSofa => '💡 Find an affordable living-room sofa';

  @override
  String get chatPromptDining => '💡 Suggest a dining set for a family of four';

  @override
  String get chatPromptDesk => '💡 Do you have a compact wooden desk?';

  @override
  String get chatPromptVoucher => '💡 How do I apply a voucher code?';

  @override
  String get chatPromptCustom =>
      '💡 Do you accept custom-size furniture orders?';

  @override
  String get chatWelcome =>
      'Hello! 🤖 I’m the smart AI assistant for My Furniture Store. I know the prices and details of the entire catalog!\n\nAsk me about furniture or advice for designing your space. ✨';

  @override
  String get chatConnectionError =>
      '✨ The AI assistant is having connection trouble. Please try again later!';

  @override
  String get geminiAssistant => 'Gemini AI Assistant';

  @override
  String get furnitureAiAssistant => '✨ Furniture AI Assistant';

  @override
  String get chatOnlineStatus => 'Online - Reading catalog data';

  @override
  String get chatInputHint => 'Ask AI about sofas, coffee tables, offers...';

  @override
  String get chatThinking => 'AI is thinking and searching products...';

  @override
  String viewMoreProducts(int count) {
    return 'View $count more products';
  }

  @override
  String get cartTitle => 'CART';

  @override
  String get cartEmptyShort => 'There are no products yet';

  @override
  String get loginToViewCart => 'Please log in to view your cart.';

  @override
  String get viewCart => 'VIEW CART';

  @override
  String get checkoutAction => 'CHECKOUT';

  @override
  String get aboutTitle => 'About My Furniture Store';

  @override
  String get contactTitle => 'Contact';

  @override
  String get aboutDescription =>
      'My Furniture Store provides furniture for modern living spaces, with home delivery and installation services.';

  @override
  String get contactDescription =>
      'Email: support@myfurniture.local\nPhone: 1900 0000\nSupport hours: 08:00–20:00 daily.';

  @override
  String get adminManageCategories => 'Category management';

  @override
  String get adminManageProducts => 'Product management';

  @override
  String get adminManageReviews => 'Review management';

  @override
  String get adminManageOrders => 'Order management';

  @override
  String get adminManageAccounts => 'Account management';

  @override
  String get adminManagePromotions => 'Promotion management';

  @override
  String get adminManageDelivery => 'Delivery management';

  @override
  String get adminQaSupport => 'Q&A & Support';

  @override
  String get adminManageRecommendations => 'Recommendation management';

  @override
  String get adminManageRevenue => 'Revenue management';

  @override
  String get backToHome => 'Back to home';

  @override
  String get refreshData => 'Refresh data';

  @override
  String get categoriesMetric => 'CATEGORIES';

  @override
  String get productsMetric => 'PRODUCTS';

  @override
  String get collectedRevenue => 'COLLECTED REVENUE';

  @override
  String get outOfStockVariants => 'OUT-OF-STOCK VARIANTS';

  @override
  String get recentOrders => 'RECENT ORDERS';

  @override
  String get noOrdersYet => 'No orders yet.';

  @override
  String loadDataError(Object error) {
    return 'Unable to load data: $error';
  }

  @override
  String get productListTitle => 'Product list';

  @override
  String get searchProductHint => 'Search by product code or name...';

  @override
  String get mainCategory => 'Main category';

  @override
  String get subCategory => 'Subcategory';

  @override
  String get allChildren => 'All subcategories';

  @override
  String get addProduct => 'Add product';

  @override
  String get productCode => 'Product code';

  @override
  String get productName => 'Product name';

  @override
  String get price => 'Price';

  @override
  String get status => 'Status';

  @override
  String get actions => 'Actions';

  @override
  String categoryNumber(int id) {
    return 'Category #$id';
  }

  @override
  String get discontinued => 'Discontinued';

  @override
  String get onSale => 'On sale';

  @override
  String loadProductsError(Object error) {
    return 'Unable to load products: $error';
  }

  @override
  String get confirmDeleteProduct => 'Confirm product deletion';

  @override
  String get confirmDeleteProductBody =>
      'Are you sure you want to delete this product? This action cannot be undone.';

  @override
  String get categoryListTitle => 'Product category list';

  @override
  String get addCategory => 'Add category';

  @override
  String get noCategories => 'There are no categories yet.';

  @override
  String get noSubcategories => 'No subcategories';

  @override
  String loadCategoriesError(Object error) {
    return 'Unable to load categories: $error';
  }

  @override
  String get confirmDeleteCategory => 'Confirm category deletion';

  @override
  String get confirmDeleteCategoryBody =>
      'Are you sure you want to delete this category? This action cannot be undone.';

  @override
  String get addNewCategory => 'Add New Category';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get categoryInformation => 'Category information';

  @override
  String get categoryName => 'Category name';

  @override
  String get categoryNameRequired => 'Category name (*)';

  @override
  String get categoryCode => 'Category code';

  @override
  String invalidCode(String field) {
    return '$field may only contain letters, numbers, hyphens (-), or underscores (_)!';
  }

  @override
  String get categoryCodeAuto =>
      'Category code (Leave blank to generate automatically)';

  @override
  String get parentCategoryOptional => 'Parent category (optional)';

  @override
  String get rootCategoryOption => 'None (This is a root category)';

  @override
  String get categoryImage => 'Category image';

  @override
  String get uploadFromDevice => 'Upload from device...';

  @override
  String selectedFile(String name) {
    return 'Selected: $name';
  }

  @override
  String get useCurrentImage => 'Use current image';

  @override
  String get noImageSelected => 'No image selected';

  @override
  String get invalidCategoryName => 'Please enter a valid category name!';

  @override
  String saveCategoryError(Object error) {
    return 'Unable to save category: $error';
  }

  @override
  String get addNewVariant => 'Add New Variant';

  @override
  String get editVariant => 'Edit Variant';

  @override
  String get color => 'Color';

  @override
  String get stockQuantity => 'Stock quantity';

  @override
  String get additionalPrice => 'Additional price (VND)';

  @override
  String get variantImages => 'Variant images';

  @override
  String get cannotReadImage =>
      'Unable to read the image data. Please select the file again.';

  @override
  String imageUploadError(Object error) {
    return 'Unable to upload image: $error';
  }

  @override
  String get invalidProductFields =>
      'Please check and correctly complete the product information fields!';

  @override
  String get selectFullCategoryPath =>
      'Please select both a main category and a subcategory';

  @override
  String saveProductError(Object error) {
    return 'Unable to save product: $error';
  }

  @override
  String get addNewProduct => 'Add New Product';

  @override
  String get editProductInformation => 'Edit Product Information';

  @override
  String get productNameRequired => 'Product name (*)';

  @override
  String get productCodeAuto =>
      'Product code (Leave blank to generate automatically)';

  @override
  String get basePrice => 'Base price';

  @override
  String get basePriceRequired => 'Base price (VND) (*)';

  @override
  String get detailedDescription => 'Detailed description';

  @override
  String get detailedDescriptionRequired => 'Detailed description (*)';

  @override
  String get productVariantsHeading =>
      'Product variants (Color, Size, Stock, Additional price)';

  @override
  String get addVariant => 'Add variant';

  @override
  String get noVariants =>
      'There are no variants yet. Click \"Add variant\" above.';

  @override
  String variantColorSize(String color, String size) {
    return '$color | Size: $size';
  }

  @override
  String variantStockPrice(Object stock, String price) {
    return 'Stock: $stock | Difference: +$price';
  }

  @override
  String get temporarilyHideProduct => 'Temporarily hide (discontinue)';

  @override
  String get hiddenProductDescription =>
      'The product will not appear on the homepage';

  @override
  String get productPreview => 'PRODUCT PREVIEW';

  @override
  String get productDiscountTitle => 'Product discount';

  @override
  String get productDiscountHint =>
      'Apply the discount to every variant during the selected period.';

  @override
  String get discountStartDate => 'Start date';

  @override
  String get discountEndDate => 'End date';

  @override
  String get noDateLimit => 'No limit';

  @override
  String get discountPercentRangeError =>
      'The discount must be greater than 0 and no more than 90%.';

  @override
  String get activeDiscountRequiredError =>
      'Enter a discount percentage before enabling the promotion.';

  @override
  String get discountDateRangeError =>
      'The end date must be after the start date.';

  @override
  String get productNamePlaceholder => 'Product Name';

  @override
  String get oakColor => 'Oak';

  @override
  String get walnutColor => 'Walnut';

  @override
  String get naturalWoodColor => 'Natural wood';

  @override
  String get brownWoodColor => 'Brown wood';

  @override
  String get whiteColor => 'White';

  @override
  String get blackColor => 'Black';

  @override
  String get greyColor => 'Grey';

  @override
  String get beigeColor => 'Beige';

  @override
  String get tanColor => 'Tan';

  @override
  String get standardSize => 'Standard';

  @override
  String get smallSize => 'S (Small)';

  @override
  String get mediumSize => 'M (Medium)';

  @override
  String get largeSize => 'L (Large)';

  @override
  String invalidNumber(String field) {
    return '$field must be a valid number!';
  }

  @override
  String integerRequired(String field) {
    return '$field must be an integer!';
  }

  @override
  String minimumValue(String field, num min) {
    return '$field must be greater than or equal to $min!';
  }

  @override
  String loadOrderListError(Object error) {
    return 'Unable to load the order list: $error';
  }

  @override
  String get rescheduledDelivery => 'Delivery rescheduled';

  @override
  String get paymentFailed => 'Failed';

  @override
  String get confirmCancelOrder => 'Confirm order cancellation';

  @override
  String get confirmCancelOrderBody =>
      'Are you sure you want to cancel this order? Inventory and voucher usage will be restored.';

  @override
  String get no => 'No';

  @override
  String get cancelOrder => 'Cancel order';

  @override
  String get orderStatusUpdated => 'Order status updated successfully!';

  @override
  String updateError(Object error) {
    return 'Unable to update: $error';
  }

  @override
  String get adminOrderManagement => 'Order Management';

  @override
  String get searchOrdersHint => 'Search by name, email, ID...';

  @override
  String get noOrdersFound => 'No orders found.';

  @override
  String orderNumber(int id) {
    return 'Order #$id';
  }

  @override
  String customerSummary(String name, String email) {
    return 'Customer: $name ($email)';
  }

  @override
  String orderDetailsCode(String code) {
    return 'Details for $code';
  }

  @override
  String orderDetailsNumber(int id) {
    return 'Order #$id details';
  }

  @override
  String get orderStatusLabel => 'Order status:';

  @override
  String get shipperOwnsDeliveryConfirmation =>
      'A shipper is handling this order. Only the shipper may confirm it as delivered.';

  @override
  String get confirmOrder => 'Confirm order';

  @override
  String get cancelOrderFull => 'Cancel order';

  @override
  String get completedOrderLocked =>
      'This order is complete or cancelled. Its status cannot be changed.';

  @override
  String get customerDeliveryInformation => 'Customer & Delivery Information';

  @override
  String get assignedShipper => 'Assigned shipper:';

  @override
  String get customerNameLabel => 'Customer name:';

  @override
  String get deliveryAddressLabel => 'Delivery address:';

  @override
  String get appointmentSlot => 'Appointment slot:';

  @override
  String get assemblyServiceLabel => 'Assembly service:';

  @override
  String assemblyRequested(String fee) {
    return 'Requested (+$fee)';
  }

  @override
  String get none => 'None';

  @override
  String get paymentSection => 'Payment';

  @override
  String get methodLabel => 'Method:';

  @override
  String get paymentStatusLabel => 'Payment status:';

  @override
  String get orderedProducts => 'Ordered products';

  @override
  String classification(String color, String size) {
    return 'Classification: $color - $size';
  }

  @override
  String get totalPaymentLabel => 'Total payment:';

  @override
  String loadAccountsError(Object error) {
    return 'Unable to load accounts: $error';
  }

  @override
  String get accountUnlocked => 'Account unlocked successfully!';

  @override
  String get accountLocked => 'Account locked successfully!';

  @override
  String changeStatusError(Object error) {
    return 'Unable to change status: $error';
  }

  @override
  String get roleUpdated => 'Role updated successfully!';

  @override
  String updateRoleError(Object error) {
    return 'Unable to update role: $error';
  }

  @override
  String resetPasswordFor(Object name) {
    return 'Reset password for $name';
  }

  @override
  String get newPasswordLabel => 'New password:';

  @override
  String passwordResetSuccess(Object password) {
    return 'Password reset successfully! New password: $password';
  }

  @override
  String resetPasswordError(Object error) {
    return 'Unable to reset password: $error';
  }

  @override
  String get confirm => 'Confirm';

  @override
  String get accountManagementTitle => 'Account management';

  @override
  String get refresh => 'Refresh';

  @override
  String get systemAccountList => 'System account list';

  @override
  String get searchAccountsHint => 'Search by name, email, phone...';

  @override
  String get noAccountsFound => 'No accounts found.';

  @override
  String get customerId => 'Customer ID';

  @override
  String get role => 'Role';

  @override
  String get operations => 'Operations';

  @override
  String get customerRole => 'Customer';

  @override
  String get locked => 'Locked';

  @override
  String get active => 'Active';

  @override
  String get unlock => 'Unlock';

  @override
  String get lock => 'Lock';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String deliveryDispatchLoadError(Object error) {
    return 'Unable to load dispatch data: $error';
  }

  @override
  String get tryAgain => 'Try again';

  @override
  String get deliveryControlCenter =>
      '🚚 Delivery Dispatch & Management Center';

  @override
  String get deliveryControlDescription =>
      'Monitor delivery and furniture installation operations and handle incidents in real time.';

  @override
  String get refreshMetrics => 'Refresh metrics';

  @override
  String get activeDispatchOrders => 'ACTIVE DISPATCH ORDERS';

  @override
  String orderCount(Object count) {
    return '$count orders';
  }

  @override
  String get totalDistance => 'TOTAL DISTANCE';

  @override
  String get collectedShippingFees => 'COLLECTED SHIPPING FEES';

  @override
  String get earnedAssemblyFees => 'INSTALLATION FEES EARNED';

  @override
  String get teamWorkloadMonitoring =>
      'Shipper & Installation Team Workload Monitoring';

  @override
  String get teamWorkloadDescription =>
      'Helps admins assign shifts and adjust orders fairly to prevent overload.';

  @override
  String get noShippers => 'There are no shipper accounts in the system.';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get unknown => 'Unknown';

  @override
  String phoneSummary(Object phone) {
    return 'Phone: $phone';
  }

  @override
  String activeDeliverySummary(Object count) {
    return 'Active: $count orders';
  }

  @override
  String completedDeliverySummary(Object count) {
    return 'Completed: $count orders';
  }

  @override
  String get deliveryScheduleTitle =>
      '📅 Delivery Time Slots & Incident Handling';

  @override
  String get deliveryScheduleDescription =>
      'Schedule installation shifts and intervene promptly when shippers report delivery issues.';

  @override
  String morningShift(Object count) {
    return '☀️ Morning ($count)';
  }

  @override
  String afternoonShift(Object count) {
    return '🌞 Afternoon ($count)';
  }

  @override
  String eveningShift(Object count) {
    return '🌙 Evening ($count)';
  }

  @override
  String issuesReschedule(Object count) {
    return 'Issues / Rescheduled ($count)';
  }

  @override
  String get noDeliveryIssues =>
      'Great! There are currently no delivery incidents or rescheduled orders.';

  @override
  String get noShiftOrders => 'There are no orders in this delivery shift.';

  @override
  String assemblyIncludedBadge(Object fee) {
    return '🛠️ ASSEMBLY INCLUDED (+$fee)';
  }

  @override
  String get acceptanceImage => 'Acceptance image';

  @override
  String get dispatchChangeShift => 'Dispatch & Change shift';

  @override
  String customerContactSummary(Object name, Object phone) {
    return '👤 Customer: $name ($phone)';
  }

  @override
  String addressSummary(Object address) {
    return '📍 Address: $address';
  }

  @override
  String get responsibleShipper => '👷 Assigned shipper:';

  @override
  String get unassigned => 'Unassigned';

  @override
  String distanceSummary(Object distance) {
    return '📏 Distance: $distance km';
  }

  @override
  String issueHistoryNotes(Object notes) {
    return '⚠️ Incident history & notes:\n$notes';
  }

  @override
  String get rescheduledSecondTime => '⚠️ Rescheduled (2nd time)';

  @override
  String get completedStatus => '✅ Completed';

  @override
  String get outForDelivery => '🚚 Out for delivery';

  @override
  String get awaitingDispatch => 'Awaiting dispatch';

  @override
  String get acceptanceImageTitle =>
      '🖼️ Installation / Delivery Acceptance Image';

  @override
  String get cannotLoadImage => 'Unable to load image.';

  @override
  String dispatchDialogTitle(Object code) {
    return 'Dispatch & Reschedule - Order #$code';
  }

  @override
  String get assignShipperRequired => 'Assign shipper (*):';

  @override
  String get chooseResponsibleShipper => '-- Choose responsible shipper --';

  @override
  String get available => 'Available';

  @override
  String get newTimeSlot => 'New service time slot:';

  @override
  String get adminDispatchNote => 'Admin dispatch note (optional):';

  @override
  String get adminDispatchNoteHint =>
      'Example: The customer requested the afternoon shift; please take extra care during installation...';

  @override
  String get mustChooseShipper =>
      '⚠️ Please choose a shipper before assigning or dispatching!';

  @override
  String get dispatchSaved => '🎉 Dispatch configuration saved successfully!';

  @override
  String get saveDispatch => 'Save changes & dispatch';

  @override
  String get confirmDelete => 'Confirm deletion';

  @override
  String confirmDeleteVoucher(Object code) {
    return 'Are you sure you want to delete voucher \"$code\" from the system?';
  }

  @override
  String get voucherDeleted => 'Voucher deleted successfully';

  @override
  String deleteVoucherError(Object error) {
    return 'Unable to delete voucher: $error';
  }

  @override
  String get voucherManagementTitle => 'Promotion Management (Vouchers)';

  @override
  String get createVoucher => 'Create New Voucher';

  @override
  String get voucherListTitle => 'Promotion Code List';

  @override
  String get searchVoucherHint => 'Search by code or campaign name...';

  @override
  String get noSystemVouchers => 'There are no vouchers in the system.';

  @override
  String get code => 'Code';

  @override
  String get campaignName => 'Campaign name';

  @override
  String get offer => 'Offer';

  @override
  String get minimumOrder => 'Minimum order';

  @override
  String get usedSupported => 'Used / Limit';

  @override
  String get expiry => 'Expiry';

  @override
  String percentageDiscount(Object value) {
    return '$value% off';
  }

  @override
  String maximumAmountSuffix(Object amount) {
    return 'Up to $amount';
  }

  @override
  String cashDiscount(Object amount) {
    return '$amount off';
  }

  @override
  String get operating => 'Active';

  @override
  String get expired => 'Expired';

  @override
  String get usageExhausted => 'Limit reached';

  @override
  String get edit => 'Edit';

  @override
  String get createNewVoucher => 'Create New Promotion Code';

  @override
  String updateVoucher(Object code) {
    return 'Update Voucher (#$code)';
  }

  @override
  String get voucherCodeHint => 'Code (e.g. SUMMER2026)*';

  @override
  String get campaignNameRequired => 'Campaign name*';

  @override
  String get conditionDescription => 'Detailed conditions';

  @override
  String get discountType => 'Discount type';

  @override
  String get percentageType => 'Percentage (%)';

  @override
  String get cashType => 'Cash discount (VND)';

  @override
  String get discountPercentField => 'Discount (%)';

  @override
  String get discountCashField => 'Discount amount (VND)';

  @override
  String get discountAmountField => 'Discount amount';

  @override
  String get maximumDiscountVnd => 'Maximum discount (VND)';

  @override
  String get minimumOrderVnd => 'Minimum order (VND)*';

  @override
  String get totalIssueLimit => 'Total issue limit*';

  @override
  String get activateImmediately => 'Activate immediately';

  @override
  String get startDate => 'Start date';

  @override
  String get endDate => 'Expiry date';

  @override
  String get saveVoucher => 'Save Voucher';

  @override
  String maximumValue(Object field, Object max) {
    return '$field must not exceed $max!';
  }

  @override
  String get editReply => 'Edit Reply';

  @override
  String get answerAndEmail => 'Answer Question & Send Email';

  @override
  String get anonymous => 'Anonymous';

  @override
  String get noEmail => 'No email';

  @override
  String customerWithEmail(Object email, Object name) {
    return 'Customer: $name ($email)';
  }

  @override
  String topicLabel(Object topic) {
    return 'Topic: [$topic]';
  }

  @override
  String get adminReplyContent => 'ADMINISTRATION REPLY:';

  @override
  String get adminReplyHint =>
      'Enter the official answer... This content will be emailed to the customer.';

  @override
  String get replyContentField => 'Reply content';

  @override
  String get processing => 'Processing...';

  @override
  String get saveReplyEmail => 'Save Reply & Send Email';

  @override
  String get adminQaCenterTitle => 'Q&A & SUPPORT MANAGEMENT CENTER';

  @override
  String get adminQaCenterDescription =>
      'Answer customer questions with automatic SMTP email notifications';

  @override
  String needsAnswer(Object count) {
    return '⏳ Needs answer ($count)';
  }

  @override
  String answeredCount(Object count) {
    return '✅ Answered ($count)';
  }

  @override
  String allQuestionCount(Object count) {
    return '🌟 All questions ($count)';
  }

  @override
  String get noUrgentQuestions =>
      'Great! There are no urgent questions awaiting answers.';

  @override
  String get noQuestionsInSection => 'No questions found in this section.';

  @override
  String fromCustomer(Object email, Object name) {
    return 'From: $name ($email)';
  }

  @override
  String get answered => '✅ Answered';

  @override
  String get urgentHandling => '⏳ Urgent';

  @override
  String get questionLabel => '❓ Question:';

  @override
  String get repliedEmailed => '💡 Replied (Email sent):';

  @override
  String get replyEmailCustomer => '💬 Reply & Email Customer';

  @override
  String minimumCharacters(Object count) {
    return 'Content must contain at least $count characters.';
  }

  @override
  String get customerLabel => 'Customer';

  @override
  String atTime(Object time) {
    return 'At: $time';
  }

  @override
  String recommendationLoadError(Object error) {
    return 'Unable to load recommendation management: $error';
  }

  @override
  String get supportRangeError =>
      'Min Support must be greater than 0% and no more than 100%.';

  @override
  String get confidenceRangeError =>
      'Min Confidence must be greater than 0% and no more than 100%.';

  @override
  String get recommendationResultRangeError =>
      'The number of recommendations must be from 1 to 20.';

  @override
  String get recommendationRebuilt => 'Recommendation data has been rebuilt.';

  @override
  String recommendationBuildSummary(
    Object baskets,
    Object message,
    Object rules,
  ) {
    return '$message Baskets: $baskets · Rules: $rules';
  }

  @override
  String get deleteAllAprioriRules => 'Delete all Apriori rules?';

  @override
  String get deleteAprioriWarning =>
      'Frequently bought together will have no data until you rebuild it.';

  @override
  String get deleteRules => 'Delete rules';

  @override
  String get recommendationManagementTitle =>
      'Recommendation Algorithm Management';

  @override
  String get recommendationManagementDescription =>
      'Monitor and tune Apriori and Content-Based recommendations.';

  @override
  String get eligibleBaskets => 'ELIGIBLE BASKETS';

  @override
  String get aprioriRules => 'APRIORI RULES';

  @override
  String get coveredProducts => 'COVERED PRODUCTS';

  @override
  String get coverage => 'COVERAGE';

  @override
  String get operationSettings => 'Operation settings';

  @override
  String get aprioriFrequentlyBoughtTogether =>
      'Apriori – Frequently bought together';

  @override
  String get aprioriHistoryDescription =>
      'Uses paid or delivered order history.';

  @override
  String get contentBasedSimilarProducts => 'Content-Based – Similar products';

  @override
  String get contentBasedDescription =>
      'Matches category, material, color, and price.';

  @override
  String get autoRebuildApriori => 'Automatically rebuild Apriori';

  @override
  String get autoRebuildDescription =>
      'Runs after the shipper confirms delivery.';

  @override
  String get maximumRecommendationResults => 'Maximum results';

  @override
  String get saveSettings => 'Save settings';

  @override
  String get rebuildApriori => 'Rebuild Apriori';

  @override
  String get parameterMeaning => 'Parameter meanings';

  @override
  String get supportExplanation =>
      'The share of eligible orders containing both products.';

  @override
  String get confidenceExplanation =>
      'The probability a customer buys product B when an order includes product A.';

  @override
  String get coverageExplanation =>
      'The share of active products with at least one frequently-bought-together rule.';

  @override
  String get thresholdExplanation =>
      'Higher thresholds produce more reliable rules, but may reduce product coverage.';

  @override
  String get contentBasedPreview => 'Preview Content-Based';

  @override
  String get sourceProduct => 'Source product';

  @override
  String get runTest => 'Run test';

  @override
  String currentAprioriRules(Object count) {
    return 'Current Apriori rules ($count)';
  }

  @override
  String get deleteAll => 'Delete all';

  @override
  String get noAprioriRules => 'No rules yet. Run “Rebuild Apriori”.';

  @override
  String get accompanyingRecommendation => 'Recommended with';

  @override
  String get updatedAt => 'Updated';

  @override
  String productListLoadError(Object error) {
    return 'Unable to load product list: $error';
  }

  @override
  String productReviewsLoadError(Object error) {
    return 'Unable to load product reviews: $error';
  }

  @override
  String get reviewApprovedSuccess => 'Review approved successfully!';

  @override
  String reviewApprovalError(Object error) {
    return 'Unable to approve review: $error';
  }

  @override
  String get confirmReject => 'Confirm rejection';

  @override
  String get confirmRejectReview =>
      'Are you sure you want to delete/reject this review?';

  @override
  String get reject => 'Reject';

  @override
  String get reviewRejectedSuccess => 'Review deleted/rejected successfully!';

  @override
  String reviewRejectError(Object error) {
    return 'Unable to reject review: $error';
  }

  @override
  String get replyToReview => 'Reply to review';

  @override
  String reviewCustomerNameLabel(Object name) {
    return 'Customer: $name';
  }

  @override
  String commentQuoted(Object comment) {
    return 'Comment: “$comment”';
  }

  @override
  String get replyContent => 'Reply content:';

  @override
  String get storeReplyHint => 'Enter the store\'s reply...';

  @override
  String get replyRequired => 'Reply content cannot be empty.';

  @override
  String sendReplyError(Object error) {
    return 'Unable to send reply: $error';
  }

  @override
  String get sendReply => 'Send reply';

  @override
  String get reviewManagementByProduct => 'Review Management by Product';

  @override
  String get aiReviewModerationDescription =>
      'AI moderates reviews when submitted: appropriate content is published automatically, profanity is blocked, and uncertain cases await admin approval.';

  @override
  String get businessProducts => 'Products';

  @override
  String get parentCategory => 'Parent category';

  @override
  String get allParentCategories => 'All parent categories';

  @override
  String get chooseSubcategory => 'Choose subcategory';

  @override
  String get subcategory => 'Subcategory';

  @override
  String get noProductsMatchFilter => 'No product data matches the filters.';

  @override
  String get averageStars => 'Average rating';

  @override
  String get totalReviews => 'Total reviews';

  @override
  String get pendingApproval => 'Pending approval';

  @override
  String reviewCountText(Object count) {
    return '$count reviews';
  }

  @override
  String pendingReviewCount(Object count) {
    return '$count pending';
  }

  @override
  String get viewDetails => 'View details';

  @override
  String productReviewHeading(Object product) {
    return 'Product reviews: $product';
  }

  @override
  String get detailedReviewList => 'Detailed Review List';

  @override
  String ratingReviewSummary(Object count, Object rating) {
    return '$rating ($count reviews)';
  }

  @override
  String get productHasNoReviews =>
      'This product has not received any reviews.';

  @override
  String get sender => 'Sender';

  @override
  String get starCount => 'Stars';

  @override
  String get customerOpinion => 'Customer opinion';

  @override
  String get time => 'Time';

  @override
  String get noComment => 'No comment';

  @override
  String get approved => 'Approved';

  @override
  String get notReplied => 'Not replied';

  @override
  String get approve => 'Approve';

  @override
  String get reply => 'Reply';

  @override
  String get deleteReview => 'Delete review';

  @override
  String get chooseRevenueRange => 'CHOOSE REVENUE REPORT RANGE';

  @override
  String get dateRangeTooLong =>
      'The date range is too long. Choose a larger aggregation level or shorten the range.';

  @override
  String get revenueManagement => 'Revenue Management';

  @override
  String get revenueManagementDescription =>
      'Analyze revenue from successfully delivered orders';

  @override
  String get reloadReport => 'Reload report';

  @override
  String get today => 'Today';

  @override
  String get last7Days => 'Last 7 days';

  @override
  String get last30Days => 'Last 30 days';

  @override
  String get thisMonth => 'This month';

  @override
  String get thisYear => 'This year';

  @override
  String get allTime => 'All time';

  @override
  String get custom => 'Custom';

  @override
  String get byDay => 'By day';

  @override
  String get byMonth => 'By month';

  @override
  String get byYear => 'By year';

  @override
  String get dateRange => 'Date range';

  @override
  String get aggregationLevel => 'Aggregation';

  @override
  String get viewReport => 'VIEW REPORT';

  @override
  String get totalRevenue => 'Total revenue';

  @override
  String get afterFeesAndOffers => 'After fees and offers';

  @override
  String get deliveredOrders => 'Delivered orders';

  @override
  String get deliveredOrdersOnly => 'Delivered orders only';

  @override
  String get productsSold => 'Products sold';

  @override
  String get totalItemsInOrders => 'Total quantity in orders';

  @override
  String get averageOrderValue => 'Average order value';

  @override
  String customerCountText(Object count) {
    return '$count customers';
  }

  @override
  String get comparePreviousPeriod => 'Comparison with previous period';

  @override
  String get ordersLabel => 'Orders';

  @override
  String previousPeriodRange(Object from, Object to) {
    return 'Previous period: $from – $to';
  }

  @override
  String previousPeriodValue(Object value) {
    return 'Previous: $value';
  }

  @override
  String get revenueComposition => 'Revenue composition';

  @override
  String get merchandiseBeforeOffers => 'Merchandise before offers';

  @override
  String get shippingFee => 'Shipping fee';

  @override
  String get assemblyFee => 'Assembly fee';

  @override
  String get estimatedDiscount => 'Estimated discount';

  @override
  String get recognizedRevenue => 'Recognized revenue';

  @override
  String voucherOrderCountText(Object count) {
    return '$count orders used a promotion code';
  }

  @override
  String get revenueOrderTrend => 'Revenue and order trend';

  @override
  String get revenue => 'Revenue';

  @override
  String get noTimelineData => 'No timeline data available.';

  @override
  String get revenueByCategory => 'Revenue by Category';

  @override
  String revenueCategoryCount(Object count) {
    return '$count categories generated revenue';
  }

  @override
  String get noCategoryRevenue => 'No category revenue available.';

  @override
  String get sold => 'Sold';

  @override
  String get share => 'Share';

  @override
  String get revenueByProduct => 'Revenue by Product';

  @override
  String revenueProductCount(Object count) {
    return '$count products generated revenue';
  }

  @override
  String get searchRevenueProductHint => 'Search by name, code, or category...';

  @override
  String get noMatchingRevenueProducts => 'No matching products found.';

  @override
  String get averageSellingPrice => 'Avg. selling price';

  @override
  String detailByGroup(Object group) {
    return 'Details $group';
  }

  @override
  String periodCountText(Object count) {
    return '$count data periods in the selected range';
  }

  @override
  String get reportingPeriod => 'Reporting period';

  @override
  String get revenueMethodology =>
      'Calculation: only delivered orders are recognized, based on completion time. Product and category revenue is merchandise value before allocating promotion codes; total revenue is the final order amount including fees and offers. Because the current data does not store discounts per product, discounts are estimated at order level.';

  @override
  String monthYear(Object month, Object year) {
    return 'Month $month/$year';
  }

  @override
  String yearValue(Object year) {
    return 'Year $year';
  }

  @override
  String get sessionExpired =>
      'You are not signed in or your session has expired.';

  @override
  String deliveryListLoadError(Object error) {
    return 'Unable to load delivery list: $error';
  }

  @override
  String get availableForOrders => 'You are available to receive orders.';

  @override
  String get unavailableForOrders => 'You are now unavailable.';

  @override
  String get shipperPortalTitle => 'Delivery & Installation Portal';

  @override
  String employeeName(Object name) {
    return 'Employee: $name';
  }

  @override
  String get refreshList => 'Refresh list';

  @override
  String activeDeliveriesCount(Object count) {
    return 'Delivering ($count)';
  }

  @override
  String completedDeliveriesCount(Object count) {
    return 'Completed ($count)';
  }

  @override
  String get noPendingDeliveries => 'There are no orders awaiting delivery.';

  @override
  String get noCompletedDeliveries => 'You have not completed any orders yet.';

  @override
  String deliveryNoteCode(Object code) {
    return 'Delivery #$code';
  }

  @override
  String rescheduledAttempt(Object count) {
    return '⚠️ RESCHEDULED (ATTEMPT $count)';
  }

  @override
  String get deliveringStatus => 'DELIVERING';

  @override
  String get successfulStatus => 'SUCCESSFUL';

  @override
  String noteText(Object note) {
    return '📝 Note: $note';
  }

  @override
  String get includesAssemblyBadge => '🛠️ INCLUDES ASSEMBLY';

  @override
  String totalCollection(Object amount) {
    return 'Total collection: $amount';
  }

  @override
  String cannotCallNumber(Object phone) {
    return 'Unable to call: $phone';
  }

  @override
  String get cannotOpenGoogleMaps => 'Unable to open Google Maps.';

  @override
  String get confirmDeliveryCompletion => 'Confirm order completion';

  @override
  String get confirmDeliveryCompletionMessage =>
      'Have you successfully delivered the furniture and completed installation (if applicable)?';

  @override
  String get confirmComplete => 'Confirm completion';

  @override
  String get deliveryCompletedSuccess =>
      '🎉 Delivery and installation confirmed successfully!';

  @override
  String get customerAbsentReason => 'Customer is not home (Reschedule)';

  @override
  String get customerRescheduleReason =>
      'Customer requested a different date/time';

  @override
  String get incorrectContactReason => 'Incorrect address or phone number';

  @override
  String get technicalIssueReason => 'Installation or product technical issue';

  @override
  String get weatherTrafficReason => 'Weather or traffic issue';

  @override
  String get reportIssue => 'Report issue';

  @override
  String get chooseIncompleteReason =>
      'Choose why the order could not be completed:';

  @override
  String get issueDetailNote => 'Detailed note / Customer request:';

  @override
  String get issueNoteHint =>
      'Example: Customer will return late and requested delivery tomorrow at 9 AM...';

  @override
  String get sendReport => 'Send report';

  @override
  String get issueReportedSuccess =>
      '⚠️ Issue recorded and order moved to Rescheduled!';

  @override
  String deliveryDetailTitle(Object code) {
    return 'Delivery details #$code';
  }

  @override
  String get deliveryAssemblySuccessful => 'Delivery & installation successful';

  @override
  String get deliveryInProgress => 'Delivery in progress...';

  @override
  String shipperAppointmentSlot(Object slot) {
    return '⏰ Appointment: $slot';
  }

  @override
  String homeAssemblyRequired(Object amount) {
    return '🛠️ HOME ASSEMBLY REQUIRED (+$amount)';
  }

  @override
  String incidentHistory(Object notes) {
    return '📝 Incident history / notes:\n$notes';
  }

  @override
  String get recipientInformation => 'Recipient information';

  @override
  String get phoneNotUpdated => 'Phone number not updated';

  @override
  String get callNow => 'Call now';

  @override
  String get openGoogleMapsDirections => 'Open Google Maps Directions';

  @override
  String deliveryItemsCount(Object count) {
    return 'Items to deliver ($count products)';
  }

  @override
  String colorSizeSummary(Object color, Object size) {
    return 'Color: $color | Size: $size';
  }

  @override
  String get orderInvoiceSummary => 'Order & Invoice Summary';

  @override
  String get merchandiseAmount => 'Merchandise:';

  @override
  String get grandTotal => 'GRAND TOTAL:';

  @override
  String paidNoCashCollection(Object method) {
    return 'Order PAID ($method). Do not collect cash.';
  }

  @override
  String collectCashCod(Object amount) {
    return 'Unpaid. Please COLLECT CASH (COD): $amount';
  }

  @override
  String get confirmDeliveryAssemblySuccess =>
      'CONFIRM DELIVERY & INSTALLATION SUCCESS';

  @override
  String get reportIssueReschedule => 'REPORT ISSUE / REQUEST RESCHEDULE';

  @override
  String get registrationLinkMissingToken =>
      'The link does not contain a password setup token.';

  @override
  String get registrationSuccess => 'Registration successful';

  @override
  String get accountSetup => 'Account setup';

  @override
  String get invalidRegistrationLink => 'This link is no longer valid';

  @override
  String get requestNewLink => 'REQUEST A NEW LINK';

  @override
  String get createYourPassword => 'Create your password';

  @override
  String get newPasswordField => 'New password';

  @override
  String get minimumEightCharacters => 'At least 8 characters';

  @override
  String get confirmPasswordField => 'Confirm password';

  @override
  String get passwordMismatch =>
      'The confirmation password does not match the new password!';

  @override
  String get completeRegistration => 'COMPLETE REGISTRATION';

  @override
  String get verificationCodeSent =>
      'A verification code has been sent to your email!';

  @override
  String get otpResent => '🔄 A new OTP has been sent to your email!';

  @override
  String get otpVerifiedSetPassword =>
      '✅ OTP verified successfully! Please set a new password.';

  @override
  String get otpRequired => 'Please enter the OTP!';

  @override
  String otpDigitsRequired(Object count) {
    return 'The OTP must contain exactly $count digits!';
  }

  @override
  String get passwordRecoverySuccess =>
      '🎉 Password recovered successfully! Please sign in again.';

  @override
  String get backPreviousStep => 'Back to previous step';

  @override
  String get backToLogin => 'Back to sign in';

  @override
  String get otpStep => '2. OTP code';

  @override
  String get newPasswordStep => '3. New password';

  @override
  String get passwordRecoveryTitle => 'Recover Password';

  @override
  String get passwordRecoveryDescription =>
      'Enter the email linked to your account. We will send an OTP so you can reset your password.';

  @override
  String get yourEmailRequired => 'YOUR EMAIL (*)';

  @override
  String get emailExample => 'Example: user@example.com';

  @override
  String get sendOtp => 'SEND OTP';

  @override
  String get verifyOtpTitle => 'Verify OTP';

  @override
  String otpEmailInstruction(Object email) {
    return 'Check “$email” (including Spam/Junk) and enter the 6-digit code below.';
  }

  @override
  String get sixDigitVerificationCode => '6-DIGIT VERIFICATION CODE';

  @override
  String resendAfterSeconds(Object seconds) {
    return 'Resend after (${seconds}s)';
  }

  @override
  String get emailNotReceived => 'Didn\'t receive the email?';

  @override
  String get resendNewCode => '🔄 Resend New Code';

  @override
  String get confirmOtp => 'CONFIRM OTP';

  @override
  String get notEntered => 'Not entered';

  @override
  String get weak => 'Weak';

  @override
  String get medium => 'Medium';

  @override
  String get strong => 'Strong';

  @override
  String get createNewPassword => 'Create New Password';

  @override
  String verifiedPasswordInstruction(Object email) {
    return 'Verification succeeded. Set a new password for “$email”.';
  }

  @override
  String get newPasswordRequired => 'NEW PASSWORD (*)';

  @override
  String get minimumSixCharactersHint => 'At least 6 characters...';

  @override
  String passwordStrength(Object strength) {
    return 'Strength: $strength';
  }

  @override
  String get confirmPasswordRequired => 'CONFIRM PASSWORD (*)';

  @override
  String get confirmNewPasswordHint => 'Re-enter the new password...';

  @override
  String get savePasswordComplete => 'SAVE PASSWORD & FINISH';

  @override
  String get aiFromRoomAndProducts => 'AI scene from room and products';

  @override
  String get aiFromRoomAndProductsDescription =>
      'Add the products you want to visualize in the room. AI will create a new image and balance placement, perspective, and lighting.';

  @override
  String get addProductToAiScene => 'Add product to scene';

  @override
  String get selectedProducts => 'Added products';

  @override
  String get removeProductFromScene => 'Remove product from scene';

  @override
  String get chooseAtLeastOneProduct =>
      'Please choose a room image and at least one product.';

  @override
  String get chatServiceBusy =>
      'The AI assistant is busy. The system will retry automatically; you can also try again in a few minutes.';

  @override
  String get retryMessage => 'Retry';

  @override
  String get chatReadyStatus => 'Ready for furniture advice';

  @override
  String get addressSaved => 'Address saved successfully.';

  @override
  String get addressDeleted => 'Address deleted.';

  @override
  String get confirmDeleteAddress =>
      'Are you sure you want to delete this address?';

  @override
  String get addressRequiredFields =>
      'Enter the recipient, phone number, and full address.';

  @override
  String get chooseSavedAddress => 'Choose a saved address';

  @override
  String get savedAddresses => 'Saved addresses';

  @override
  String get useThisAddress => 'Use this address';

  @override
  String get revenueByMonthDashboard => 'Revenue by month';

  @override
  String get ordersByMonthDashboard => 'Successful delivery rate by month';

  @override
  String get noDashboardChartData => 'No chart data is available yet.';

  @override
  String get supportChatTitle => 'SUPPORT CHAT';

  @override
  String get supportChatDescription =>
      'Chat directly with our customer support team.';

  @override
  String get newSupportConversation => 'New conversation';

  @override
  String get createSupportConversation => 'Start conversation';

  @override
  String get supportTopic => 'Support topic';

  @override
  String get supportFirstMessageHint =>
      'Describe the issue you need help with...';

  @override
  String get supportFirstMessageValidation =>
      'The first message must contain at least 10 characters.';

  @override
  String get supportMessageTooLong =>
      'A message cannot exceed 4,000 characters.';

  @override
  String get noSupportConversations =>
      'You do not have any support conversations yet.';

  @override
  String get noConversationSelected => 'No conversation selected';

  @override
  String get chooseConversationHint =>
      'Choose a conversation on the left or start a new one.';

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String get supportMessageHint => 'Type a message...';

  @override
  String get sendSupportMessage => 'Send message';

  @override
  String get adminSupport => 'Support team';

  @override
  String get supportOnline => 'Online';

  @override
  String get supportConnecting => 'Connecting';

  @override
  String get supportReconnecting => 'Reconnecting';

  @override
  String get supportOffline => 'Offline';

  @override
  String get waitingForAdmin => 'Waiting for support';

  @override
  String get waitingForCustomer => 'Waiting for your reply';

  @override
  String get supportClosed => 'Closed';

  @override
  String get supportActive => 'Active';

  @override
  String get supportConversationClosed =>
      'This conversation is closed. Start a new conversation if you need more help.';

  @override
  String get backToConversations => 'Back to conversations';

  @override
  String get adminSupportInboxTitle => 'REALTIME SUPPORT INBOX';

  @override
  String get adminSupportInboxDescription =>
      'Monitor and reply to customer conversations in real time.';

  @override
  String get needsAdminReply => 'Needs reply';

  @override
  String get awaitingCustomer => 'Waiting for customer';

  @override
  String get allSupportConversations => 'All';

  @override
  String get searchSupportConversation => 'Search customer, email...';

  @override
  String get noAdminSupportConversations => 'No matching conversations.';

  @override
  String get adminChooseConversation =>
      'Choose a conversation to start helping the customer.';

  @override
  String get assignToMe => 'Assign to me';

  @override
  String assignedAdmin(String name) {
    return 'Assigned: $name';
  }

  @override
  String get reopenConversation => 'Reopen conversation';

  @override
  String get closeConversation => 'Close conversation';

  @override
  String get adminClosedConversationHint =>
      'This conversation is closed. Reopen it to continue chatting.';

  @override
  String get adminSupportReplyHint => 'Type your reply to the customer...';

  @override
  String get adminReplyEmailNotice =>
      'The customer will receive the realtime message and an email notification.';

  @override
  String get supportIsTyping => 'Support is typing...';

  @override
  String get customerIsTyping => 'Customer is typing...';

  @override
  String get shipperProfileTitle => 'Delivery profile';

  @override
  String get vehicleType => 'Vehicle type';

  @override
  String get vehiclePlate => 'License plate';

  @override
  String get serviceArea => 'Service area';

  @override
  String get maxConcurrentDeliveries => 'Maximum concurrent deliveries';

  @override
  String get canHandleBulkyItems => 'Can handle bulky items';

  @override
  String get canProvideAssembly => 'Can provide assembly service';

  @override
  String get shiftEnd => 'End shift';

  @override
  String get shiftAvailable => 'Available';

  @override
  String get shiftDelivering => 'Delivering';

  @override
  String get shiftBreak => 'On break';

  @override
  String get deliveryDirections => 'Directions';

  @override
  String get callCustomer => 'Call customer';

  @override
  String get acceptDelivery => 'Accept assignment';

  @override
  String get rejectDelivery => 'Reject assignment';

  @override
  String get rejectDeliveryTitle => 'Reject delivery assignment';

  @override
  String get rejectReason => 'Rejection reason';

  @override
  String get assignmentAccepted => 'Delivery assignment accepted.';

  @override
  String get assignmentRejected =>
      'The order was returned to Admin for reassignment.';

  @override
  String get pickedUpFromWarehouse => 'Picked up from warehouse';

  @override
  String get pickedUpConfirmed => 'Warehouse pickup confirmed.';

  @override
  String get startDelivery => 'Start delivery';

  @override
  String get deliveryOnTheWay => 'The order is on the way.';

  @override
  String get arrivedDestination => 'Arrived at destination';

  @override
  String get arrivedNotification => 'Arrival has been recorded.';

  @override
  String get verifyRecipient => 'Verify recipient';

  @override
  String get sendOtpByEmail => 'Send OTP by email';

  @override
  String get deliveryOtpLabel => '6-digit OTP';

  @override
  String get verifyOtp => 'Verify';

  @override
  String get otpVerified => 'OTP verified';

  @override
  String get otpSent => 'OTP was sent to the customer\'s email.';

  @override
  String get otpMustBeSixDigits => 'OTP must contain exactly 6 digits.';

  @override
  String get otpVerifiedSuccess => 'OTP verified successfully.';

  @override
  String get actualRecipientName => 'Actual recipient name';

  @override
  String get chooseDeliveryProof => 'Take/select proof photo';

  @override
  String get changeDeliveryProof => 'Change proof photo';

  @override
  String get confirmDelivered => 'Confirm successful delivery';

  @override
  String get deliveryStatusAssigned => 'Waiting for shipper';

  @override
  String get deliveryStatusAccepted => 'Assignment accepted';

  @override
  String get deliveryStatusPickedUp => 'Items picked up';

  @override
  String get deliveryStatusShipping => 'Out for delivery';

  @override
  String get deliveryStatusArrived => 'Arrived at destination';

  @override
  String get deliveryOtpRequired => 'Please verify the recipient OTP.';

  @override
  String get deliveryProofRequired => 'Please upload a delivery proof photo.';

  @override
  String get deliveryRecipientRequired =>
      'Please enter the actual recipient name.';

  @override
  String get attachIssueProof => 'Attach incident photo';

  @override
  String get confirmCollectedPayment => 'Confirm payment collection';

  @override
  String confirmCollectedPaymentMessage(String amount) {
    return 'Confirm that you collected exactly $amount from the customer?';
  }

  @override
  String get paymentCollectedSuccess =>
      'Payment collection recorded successfully.';

  @override
  String get collectPaymentBeforeComplete =>
      'Confirm COD/POS payment collection before completing delivery.';

  @override
  String amountToCollect(String amount) {
    return 'Amount to collect: $amount';
  }

  @override
  String paymentMethodSummary(String method) {
    return 'Method: $method';
  }

  @override
  String get paymentCollected => 'Full payment collected';

  @override
  String get paymentCollectionNote => 'Collection note (optional)';

  @override
  String get addPaymentProof => 'Add payment proof photo';

  @override
  String get changePaymentProof => 'Change payment proof photo';

  @override
  String get confirmPaymentCollected => 'Confirm payment collected';

  @override
  String get handoverPending => 'Waiting for shipper handover';

  @override
  String get handoverSubmitted => 'Waiting for Admin confirmation';

  @override
  String get handoverConfirmed => 'Reconciled';

  @override
  String get handoverRejected => 'Needs review';

  @override
  String handoverStatusSummary(String status) {
    return 'Reconciliation: $status';
  }

  @override
  String get reconciliationTab => 'Reconciliation';

  @override
  String get performanceTab => 'Performance';

  @override
  String get byWeek => 'By week';

  @override
  String get collectionReconciliationTitle => 'Collections and reconciliation';

  @override
  String get totalCollected => 'Collected';

  @override
  String get pendingHandover => 'Pending handover';

  @override
  String get confirmedHandover => 'Confirmed';

  @override
  String submitMoneyHandover(int count) {
    return 'Submit $count collections';
  }

  @override
  String get reconciliationSubmittedSuccess =>
      'Money handover request sent to Admin.';

  @override
  String get noCollectedPayments => 'No collections in this period.';

  @override
  String get personalPerformanceTitle => 'Personal performance';

  @override
  String get activeOrdersMetric => 'Active deliveries';

  @override
  String get completedOrdersMetric => 'Completed deliveries';

  @override
  String get failedDeliveriesMetric => 'Failed attempts';

  @override
  String get totalDistanceMetric => 'Total distance';

  @override
  String get onTimeRateMetric => 'On-time rate';

  @override
  String get rescheduleCountMetric => 'Reschedules';

  @override
  String get averageDeliveryTimeMetric => 'Average delivery time';

  @override
  String minuteCount(int count) {
    return '$count minutes';
  }

  @override
  String get performanceTrend => 'Daily details';

  @override
  String get noPerformanceData => 'No performance data yet.';

  @override
  String performanceTrendSummary(int completed, int failed, double distance) {
    return 'Completed $completed · Failed $failed · $distance km';
  }

  @override
  String adminOnTimeRate(double rate) {
    return 'On time $rate%';
  }

  @override
  String adminFailedAttempts(int count) {
    return 'Failed $count';
  }

  @override
  String get adminReconciliationTitle => 'Collection reconciliation';

  @override
  String get adminReconciliationDescription =>
      'Confirm COD/POS collections handed over by shippers.';

  @override
  String waitingHandoverSummary(int count, String amount) {
    return 'Awaiting confirmation: $count · $amount';
  }

  @override
  String get noReconciliationEntries => 'No reconciliation records.';

  @override
  String get paymentProof => 'Payment proof';

  @override
  String get confirmHandover => 'Confirm handover';

  @override
  String get confirmMoneyHandoverTitle => 'Confirm money handover';

  @override
  String get rejectReconciliationTitle => 'Return reconciliation';

  @override
  String get reconciliationNoteOptional => 'Note (optional)';

  @override
  String get rejectionReasonRequired => 'Reason for requesting review';

  @override
  String get handoverConfirmedSuccess => 'Shipper money handover confirmed.';

  @override
  String get reconciliationRejectedSuccess =>
      'Shipper was asked to review the reconciliation.';

  @override
  String get shipperCancelOrder => 'Cancel order';

  @override
  String get shipperCancelWarning =>
      'This will cancel the order, restore inventory, and cannot be undone. The admin and customer will be notified.';

  @override
  String get cancellationReason => 'Cancellation reason';

  @override
  String get cancellationNote => 'Detailed note';

  @override
  String get cancellationNoteHint => 'Describe the order condition (optional)';

  @override
  String get shipperCancelCustomerRefused => 'Customer refused the delivery';

  @override
  String get shipperCancelDamagedGoods =>
      'Goods are damaged or unsafe to deliver';

  @override
  String get shipperCancelIncorrectOrder =>
      'Incorrect product or order information';

  @override
  String get shipperCancelUnsafeDelivery =>
      'Delivery cannot be completed safely';

  @override
  String get otherReason => 'Other reason';

  @override
  String get optionalCancellationProof => 'Cancellation proof photo (optional)';

  @override
  String get cancellationProof => 'Cancellation proof';

  @override
  String get shipperCancelSuccess => 'Order cancelled and admin notified.';

  @override
  String get paidOrderCancellationRequiresAdmin =>
      'This order is paid or collected; an admin must handle the refund before cancellation.';

  @override
  String deliveryHistoryCount(int count) {
    return 'History ($count)';
  }

  @override
  String showMoreColors(int count) {
    return 'Show $count more colors';
  }

  @override
  String get showFewerColors => 'Show less';
}
