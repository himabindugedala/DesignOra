# DesignOra

## 1. Project Overview

DesignOra is a gender-inclusive custom fashion e-commerce platform that connects customers with independent fashion designers.

The main idea is to allow customers to:

- Explore existing fashion designs
- Explore independent designers
- Select a designer
- Chat with the designer about customization
- Share requirements and inspiration images
- Provide or select their measurements
- Receive customized outfit previews
- View 3D previews
- Use virtual try-on
- Approve, reject, or request further customization
- Purchase the final outfit
- Track the order until delivery

DesignOra supports both **men's and women's fashion** and should feel like a professional modern e-commerce platform similar in usability to Meesho, Amazon, and Flipkart, while maintaining a completely original DesignOra visual identity.

---

# 2. User Roles

DesignOra has exactly three user roles:

1. Customer
2. Designer
3. Tailor

The role must be selected during login/registration.

After login, the user must see **only the interface belonging to the selected role**.

### Customer
Only customer features and customer data should be visible.

### Designer
Only designer features, designer portfolio, requests, chats, customization workspace and designer-related data should be visible.

### Tailor
Only tailor dashboard, assigned stitching requests and tailor-related data should be visible.

There must be **NO demo switcher** or role-switching interface after login.

---

# 3. Public Website Before Login

When a visitor opens DesignOra without logging in, the website should behave only as a **public fashion discovery website**.

Visitors can:

- View the DesignOra brand
- Explore sample fashion designs
- Explore designers
- View basic design information
- Learn about the platform
- Navigate through public website pages

Visitors should NOT be able to:

- Place orders
- Buy products
- Add products to cart
- Add products to wishlist
- Chat with designers
- Request customization
- Access customer dashboards
- Access designer dashboards
- Access tailor dashboards

Login is required for all transactional and personalized functionality.

---

# 4. Customer Experience

After selecting **Customer** and logging in, the customer should enter the customer interface.

The customer home page should provide:

- Explore Designs
- Explore Designers
- Search
- Categories
- Gender selection
- Outfit categories
- Filters
- Wishlist
- Cart
- Orders
- Profile

The home page should NOT contain every section vertically on one long scrolling page.

Navigation should work like a professional e-commerce website:

- Header/navigation
- Search
- Category navigation
- Separate pages
- Product/design pages
- Designer pages
- Cart page
- Wishlist page
- Order page
- Profile page

The website should rely on proper navigation rather than excessive vertical scrolling.

---

# 5. Explore Designs

Customers can browse designs created by designers.

Designs should support:

- Men's clothing
- Women's clothing
- Different outfit categories
- Different colors
- Different fabrics
- Different patterns
- Different styles
- Different price ranges

Each design should display:

- Outfit images
- Designer name
- Price
- Rating
- Available customization option
- Basic outfit information

Prices should start from **₹500**.

When a customer selects an outfit, the available actions should be:

### Chat with Designer for Customisation

This opens a GPT-style chat interface with the designer who created that outfit.

The customer can:

- Explain requirements
- Ask for changes
- Send inspiration/reference images
- Discuss fabric
- Discuss color
- Discuss sleeves
- Discuss neckline
- Discuss length
- Discuss other supported customization requirements

### Buy

This purchases the selected outfit directly.

**Buy Now must NOT automatically add the item to the cart.**

The customer should have separate:

- Buy Now
- Add to Cart
- Wishlist

actions.

---

# 6. Explore Designers

Customers can separately explore designers.

Designer profiles should contain:

- Designer name
- Profile image
- Bio
- Specialization
- Portfolio
- Designs
- Ratings
- Reviews
- Availability
- Experience
- Supported outfit categories

Customers can select a designer and start a GPT-style chat.

The customer communicates their requirements directly with the selected designer.

There must be **NO designer comparison feature**.

---

# 7. Customer Customization Flow

Customers cannot create outfits themselves.

There must be **NO "Create Your Style" feature for customers.**

There must be **NO Customer Custom Studio.**

Only designers can create and customize outfits.

The customer customization flow is:

1. Customer selects an existing design OR selects a designer.
2. Customer chooses "Chat with Designer for Customisation".
3. Customer communicates requirements through GPT-style chat.
4. Customer can upload inspiration/reference images.
5. Customer provides measurements or selects saved measurements.
6. Designer creates/customizes the outfit.
7. Designer sends the preview to the customer.
8. Only after receiving the designer's preview, the customer gets the preview action options.
9. Customer can select:
   - Accept
   - Ignore
   - Customize
10. If Accept → proceed to purchase.
11. If Ignore → the preview is dismissed.
12. If Customize → customer continues discussing changes with the designer.

---

# 8. Measurements

Customers must be able to enter and save their measurements.

The platform should support:

- Manual measurement entry
- Selecting saved measurements
- Updating measurements
- Using saved measurements for future orders

Measurements should be associated with the customer's profile.

The system should make it easy to reuse saved measurements instead of entering them for every order.

---

# 9. Style Preference Profile

Customers should have a personalized style preference profile.

The profile can store:

- Preferred colors
- Preferred patterns
- Preferred outfit types
- Preferred styles
- Gender/category preferences
- Saved measurements
- Inspiration images

This information can later be used to improve design discovery and personalization.

---

# 10. Inspiration Images

Customers should be able to upload inspiration/reference images.

These images can be used during designer communication to explain:

- Desired style
- Color
- Pattern
- Sleeves
- Neckline
- Outfit shape
- Length
- Overall appearance

Images should be stored securely using cloud storage.

---

# 11. Designer Preview

The designer is responsible for creating the customized outfit.

When the designer sends a preview, the customer should be able to see:

- Outfit preview
- Design details
- Selected measurements
- Estimated price
- Customization details

The customer can then choose:

### Accept
Proceed toward ordering.

### Ignore
Dismiss the preview and return to the conversation/design flow.

### Customize
Continue chatting with the designer for additional changes.

---

# 12. 3D Preview

The platform should provide a functional web-based 3D outfit preview.

When the customer selects **3D Preview**, the outfit should appear in an interactive 3D viewer.

The 3D viewer should support:

- Rotation
- Zoom
- Basic interaction
- Different viewing angles

The 3D preview must be implemented as an actual working prototype feature, not just a static image placeholder.

---

# 13. Virtual Try-On

The platform should provide a functional virtual try-on experience.

When the customer selects **Virtual Try-On**:

1. The customer is asked to upload their image.
2. The uploaded image is displayed.
3. The selected outfit is applied as the try-on result.
4. The customer can view the outfit on their uploaded photo.

The prototype should provide a convincing working try-on experience rather than only showing an upload button.

---

# 14. Customer Cart

Cart and Buy Now must be separate.

### Add to Cart

Adding a design to cart stores it in the customer's cart.

The customer can:

- View cart
- Change quantity where applicable
- Remove items
- Proceed to checkout

### Buy Now

Buy Now must directly start the purchase/checkout flow.

Buy Now should NOT first add the item to the cart.

---

# 15. Wishlist

Wishlist must be separate from the cart.

Customers can save designs to their wishlist.

Wishlist should have:

- Saved designs
- Remove option
- Move/add to cart
- Buy option

---

# 16. Checkout and Payment

After accepting a customized design or purchasing a ready-made design, the customer proceeds to checkout.

Checkout should collect:

- Customer name
- Phone number
- Delivery address
- City
- State
- Pincode

The customer should see a transparent price breakdown.

Example:

- Designer charge
- Fabric charge
- Stitching charge
- Delivery charge
- Total amount

Prices start from **₹500**.

Payment should be integrated using **Razorpay**.

---

# 17. Order Tracking

Customers should be able to track their orders.

Possible order stages:

1. Design Confirmed
2. Customization Completed
3. Sent for Stitching
4. Stitching in Progress
5. Ready for Dispatch
6. Shipped
7. Out for Delivery
8. Delivered

The customer should be able to view order details and status from the customer dashboard.

---

# 18. Customer Chat

Chat should look and behave like a modern GPT-style conversational interface.

It should support:

- Text messages
- Image uploads
- Design references
- Previous conversation history
- Design preview messages
- Designer responses

Customers should be able to access previous chats and previous design previews.

Each customer-design interaction should maintain its own conversation history.

---

# 19. Designer Experience

Designers register and create their own accounts.

Designer profiles should contain:

- Name
- Profile photo
- Bio
- Experience
- Specialization
- Portfolio
- Availability
- Ratings
- Reviews
- Supported outfit categories

Designers can upload their existing designs with:

- Outfit images
- Price
- Category
- Gender
- Fabric
- Color
- Pattern
- Description
- Customization availability

---

# 20. Designer Dashboard

The designer dashboard should include:

- Dashboard
- Portfolio
- My Designs
- Customer Requests
- Chats
- Customization Workspace
- Preview Management
- Orders
- Tailor Requests
- Availability
- Profile

The designer should only see their own designs, customers, chats and requests.

One designer must NOT see another designer's private workspace or customer conversations.

---

# 21. Designer Customization Workspace

Only designers can customize outfits.

There must be NO customer-side design creation tool.

The designer customization workspace should allow designers to modify supported outfit properties such as:

- Neckline
- Sleeves
- Colors
- Fabrics
- Patterns
- Outfit length
- Other supported outfit details

The designer should receive a clear customer requirement summary.

The designer can create multiple versions of an outfit.

For example:

- Version 1
- Version 2
- Version 3

The designer can send different previews to the customer for approval.

---

# 22. Designer and Tailor Workflow

Customers do NOT select tailors.

Customers only select designers.

After customization is approved, the designer can choose a registered tailor if stitching is required.

Designer workflow:

1. Receive customer request.
2. Chat with customer.
3. Understand requirements.
4. Customize outfit.
5. Send preview.
6. Receive customer approval.
7. Select a suitable tailor.
8. Send stitching request to tailor.
9. Tailor stitches the outfit.
10. Tailor updates stitching status.
11. Outfit is prepared for delivery.

---

# 23. Tailor Experience

Tailors register and create tailor accounts.

Tailors do NOT interact directly with customers for selecting or ordering outfits.

Tailors receive stitching requests from designers.

The tailor dashboard should show:

- Stitching Requests
- Accepted Requests
- Active Stitching
- Completed Stitching
- Delivery Information
- Status Updates
- Earnings/Payments

Each stitching request should contain:

- Outfit details
- Design preview
- Measurements
- Customer requirements
- Stitching instructions
- Delivery address
- Required completion information

The tailor can accept a request and update stitching status.

Payment to the tailor is handled through the designer-side workflow.

---

# 24. Gender Inclusivity

DesignOra must NOT be a women-only fashion platform.

It must support:

### Women
Examples:

- Sarees
- Kurtis
- Dresses
- Tops
- Skirts
- Gowns
- Ethnic wear
- Western wear

### Men
Examples:

- Shirts
- T-Shirts
- Trousers
- Suits
- Kurtas
- Sherwanis
- Ethnic wear
- Western wear

The platform should be expandable to additional categories in the future.

Gender and outfit categories should be integrated naturally into search, filters and product discovery.

---

# 25. Navigation and UI Requirements

The UI should be inspired by the usability patterns of professional e-commerce platforms such as:

- Meesho
- Amazon
- Flipkart

However, DesignOra must have its own branding and visual identity.

Important requirements:

- No single long scrolling homepage containing every feature.
- Use proper pages and navigation.
- Use header/navigation menus.
- Use search.
- Use category navigation.
- Use product cards.
- Use filters.
- Use separate pages for designs, designers, cart, wishlist, orders and profile.
- Keep important actions easily accessible.
- Make the experience responsive for desktop and mobile.

---

# 26. Features That Must NOT Exist

The following features must NOT be included:

- ❌ Customer "Create Your Style"
- ❌ Customer-side outfit creation
- ❌ Customer Custom Studio
- ❌ Tailor selection by customers
- ❌ Designer comparison feature
- ❌ Demo switcher
- ❌ Role switching after login
- ❌ Customer access to designer dashboard
- ❌ Customer access to tailor dashboard
- ❌ Designer access to another designer's private workspace
- ❌ Buy Now automatically adding to cart
- ❌ Long single-page scrolling for all sections

---

# 27. Main Customer Flow

```text
Website Visit
      ↓
Public Website
      ↓
Login / Register
      ↓
Select Customer
      ↓
Customer Dashboard
      ↓
Explore Designs / Explore Designers
      ↓
Select Design OR Designer
      ↓
Chat with Designer
      ↓
Share Requirements + Inspiration
      ↓
Enter / Select Measurements
      ↓
Designer Creates Custom Design
      ↓
Designer Sends Preview
      ↓
3D Preview / Virtual Try-On
      ↓
Accept / Ignore / Customize
      ↓
Accept
      ↓
Checkout
      ↓
Address
      ↓
Transparent Price Breakdown
      ↓
Razorpay Payment
      ↓
Order Tracking
      ↓
Delivery
