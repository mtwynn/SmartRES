## Smart Real Estate Signs (SmartRES)

### Team
Michael Huang   
Tam Nguyen  
Michael Mac  
Erick Samano  
Jeff Huang  


### App Description
SmartRES is the solution for real estate agents to replace traditional painted real estate signs with digital signs that are capable of functions like displaying agent information, interior views of the property, video tours and conferencing, and even data collection. The software side of the product consists of two parts:
1) The mobile application (currently with iOS) allows agents to review and update their signs at their properties, which will happen in real time.
2) The digital signs will use Raspberry Pi's (model Zero W) with open-source software and Python scripts to compute, display, and retrieve data. 

### App Idea Evaluation
Evaluate app across the following categories using the [App Evaluation Protocol](https://courses.codeath.com/courses/ios_university/pages/group_project/01_app_brainstorming_guide).

- *Mobile*

- *Story*

- *Market*

- *Habit*: 
   
- *Scope*:

---

### User Stories

**Required Must-have Stories**
- [x] User can upload pictures  
- [x] User can view feed of other pictures posted to the site  
- [x] User can submit a request to "purchase" a picture  

**Optional Nice-to-have Stories**
- [x] User can search for by tag

---
### Screen Archetypes

 * Login Screen
     * User can login
     * User can register for an account
 * Property Collection Screen
     * User can upload new properties
     * User can delete existing properties
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

**Tab Navigation** (Tab to Screen)
 * Property Collection Screen
 * Profile Screen

---
### Walkthroughs
### Login View
![LoginView](/Augma/wireframes/LoginView.png?raw=true)

### Gallery View
![GalleryView](/Augma/wireframes/GalleryView.png?raw=true)

### Product View
![ProductView](/Augma/wireframes/ProductView.png?raw=true)
---

## Login/Signup

<img src='https://i.imgur.com/9Oz79bp.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

## Augmented Reality (AR) View

<img src='http://g.recordit.co/MaHw0P1ZYS.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

## Upload a picture

<img src='https://i.imgur.com/ub2vcfv.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

## Profile page

<img src='https://i.imgur.com/8QqgTJR.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

## Searching and viewing a picture
<img src='http://g.recordit.co/Q1KwpA8ngE.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

### App Pitch Presentation Deck


---
### Future Implementation/Ideas

Todo: 
- Create a working executable for Python script 
- When user deletes a property, all associated images must go with it
- Delete images needs more verification cases (1, 1,2,3, 1-5)
- Regex verifications for signup and add property
- Compress images before upload to reduce bandwidth impact
- Remember me button using UserDefaults
- Restyle Delete images button
- GPS pinpointing for add property
- Edit property details
