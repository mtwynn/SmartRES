## Smart Real Estate Signs (SmartRES)

### Team
Michael Huang   
Tam Nguyen  
Michael Mac  
Erick Samano  
Jeff Huang  

---

### App Description
SmartRES is the solution for real estate agents to replace traditional painted real estate signs with digital signs that are capable of functions like displaying agent information and interior views of the property, video tours and conferencing, and even perform data collection. The software side of the product consists of two parts:
1) The mobile application (currently with iOS) allows agents to review and update the digital signs at their properties, which will happen in real time.
2) The digital signs will use Raspberry Pi's (model Zero W) with open-source software and Python scripts to compute, display, and retrieve data. 

---

### User Stories
**Required Must-have Stories**
- [ ] Delete images needs more verification cases (1, 1,2,3, 1-5)
- [X] Regex verifications for signup and add property
- [X] Edit property details

**Optional Nice-to-have Stories**
- [X] Remember Me Button
- [ ] Reverse geocoding for add property
- [X] Search properties
    - [ ] With various filters
- [ ] Video upload available
- [X] Map view of all properties using Geolocation services (Used Native iOS Mapkit) 
- [ ]Integration with Firebase

---

### Screen Archetypes
 * Login Screen
     * User can login
     * User can register for an account
     
 * Property Collection Screen
     * User can upload new properties
     * User can delete existing properties
     * Users can "fuzzy" search for properties by street name/house number
     
 * Map View Screen
     * User can view the locations of their properties on a map 
     * Users can search for their existing properties and locations
     * Users can add their current location as a new property if they choose to
     
 * Profile Screen
     * User can see their agent information and real-estate logo 
     * User can add and change a profile picture
     * User can log out
     
 * Main Property View Screeen
     * User can view a automatically/manually rotating slideshow of images related to this property
     * User can add new images
     * User can delete old images 
     
---

### Navigation
**Tab Navigation**
 * Property Collection Screen
 * Map View
 * Profile Screen
 
---

## Login/Signup
+<img src="/gifs/Login.gif?raw=true" width="300px">
+<img src="/gifs/Signup.gif?raw=true" width="300px">

## Property Collection
<img src="/gifs/Property_Collection.gif?raw=true" width="300px">

## Add Property
<img src="/gifs/Add_Property.gif?raw=true" width="300px">

## Edit Property
<img src="/gifs/Add_Images.gif?raw=true" width="300px">

## Profile


## Sign View (currently from Desktop)
<img src="/gifs/Sign_Demo_View.gif?raw=true">

---

### App Pitch Presentation Deck

---

### Future Implementation/Ideas

---


### Todo
- [ ] Create a working executable for Python script 
- [ ] Restyle Delete images button
