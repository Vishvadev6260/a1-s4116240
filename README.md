The Melbourne Community Event Finder application exists to help users find local events taking place in Melbourne. Users can find and view events through the application while also RSVPing and accessing complete event details. Users can find events through the app's robust search system which enables them to select events based on categories and locations and specific dates. Users can use the app's interactive map to find event locations and get directions to these places.

## Features
Users can find events through the search function which allows them to search by name and category and location.
Users can confirm their attendance at events through the app's RSVP system.
Users can access complete event information through the app which includes venue details and event descriptions and start and end times.
The application enables users to view event locations through interactive maps which also provide route directions.
Users who attend events can provide feedback and ratings through the app's review system.
The app provides event recommendations that match your individual preferences.

## Technologies Used
The app development process for the user interface used SwiftUI as its main framework.
The MapKit framework enables users to view event locations through interactive maps.
The app uses URLSession to perform network requests which retrieve event data from external APIs.
The application retrieves Melbourne event information through the Meetup API.

## Setup Instructions

### Prerequisites
The application requires these essential components for operation:
The application needs Xcode version 13 or later installed on your system.
The application requires CocoaPods for external dependency management.

### Running the App on Your Local Machine Requires These Steps
1. You can retrieve this repository through Git by using the following command:
   ```bash
   git clone https://github.com/yourusername/MelbourneCommunityEventFinder.git
API Key Setup
The application requires Meetup API keys to retrieve event information.
The following steps will help you obtain your API key:
Create a developer account through Meetup API before proceeding.
Access your API key through the API Keys section.
Insert your API key into the NetworkManager.swift file by setting it to the apiKey variable.
Configuration
The application retrieves data for Melbourne through its default configuration. Users can change the city selection and event categories to suit their needs.

&&&
