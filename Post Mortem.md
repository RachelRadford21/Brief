# Post-Mortem

## Project Overview and Objectives

**Brief** is an app for article management with intelligent summarization capabilities using Apple's Natural Language framework. The app allows users to save and summarize articles, create and edit notes, use Siri to open articles and notes, and share content.  
My goal was to build a fully native iOS application that leveraged machine learning concepts for article summarization while maintaining an intuitive, user-friendly interface.

---

## Technical Journey

### CoreML Exploration

When I began this project, I knew I wanted to push my technical boundaries. I initially aimed to use CoreML for summarization but quickly discovered there wasn't a pre-built summarization model available in Apple's library. The closest option was a text classification model, which wouldn’t meet my needs.

After research, I decided to create my own CoreML model using the CNN/DailyMail dataset, Python, and Google Colab. This became my first significant challenge:

- I had some Python experience but was new to training ML models.
- The process involved substantial trial and error.
- I relied on Google Colab, Claude, and ChatGPT to navigate unfamiliar territory.

After successfully building the model, integrating it introduced another hurdle: the model file was so large it caused issues pushing to GitHub. I implemented Git LFS (Large File Storage) to resolve this.

Later, I realized I had accidentally used the BERT model instead of the BART summarization model, forcing me to remove the model from my app — damaging my project in the process. I managed to revert without losing critical code, and my second attempt with the BART model went much more smoothly thanks to the lessons learned.

Despite these efforts, the summarization results still fell short of expectations. After considerable work, I decided to shift fully to Apple's Natural Language framework for summarization.

---

### Natural Language Framework Implementation

Working with Apple’s Natural Language framework was challenging due to limited documentation and examples specific to article summarization.  
I relied heavily on AI tools like Claude and ChatGPT, but always worked to deeply understand and clean up generated code — removing unused or dead functions to create a streamlined summarization class that:

- Implemented sentence tokenization and ranking,
- Removed non-essential functionality,
- Produced reasonably effective summarizations.

A lingering issue was filtering out unwanted metadata from article summaries. When I considered postponing further improvements, I explored whether I could extract content specifically from `<body>` tags.  
Integrating **WebKit** to parse HTML helped to significantly enhance the summarization quality.

---

### Apple App Intents & Siri Integration

Implementing **App Intents** for Siri functionality opened another new territory.  
Resources from Stewart Lynch and AI assistance helped, but I encountered conflicting information due to Apple's evolving APIs. I chose the newer approach to stay aligned with current best practices.

While Siri integration proved inconsistently reliable and slow — I ultimately achieved a stable implementation.

---

### Share Sheet Integration

Adding Share Sheet functionality was relatively straightforward.  
There were some difficulties with identifying the exact properties needed in the Info.plist, but nothing major.  
Adding an in-app share sheet was particularly smooth, and native iOS sharing capabilities integrated seamlessly into the app.

---

## Technical Insights

- **Machine Learning Integration:** Apple's frameworks often strike the best balance of capability and simplicity for iOS apps. Building custom CoreML models requires substantial expertise and data.
- **Natural Language Processing:** While under-documented, Apple's Natural Language framework offers powerful tokenization and sentence-ranking once properly implemented.
- **WebKit Integration:** Combining WebKit parsing with Natural Language processing provided a practical solution for clean content extraction and summarization.

---

## AI Tool Usage

I have a love/hate relationship with AI assistants like Claude and ChatGPT.  
They were invaluable for exploring unfamiliar concepts, but diminishing returns become clear with excessive reliance.  
I tend to use them as “rubber duck” debugging partners — prompting me to deeply understand and question suggested solutions.  
In some situations, heavier reliance was unavoidable, but overall, the experience strengthened my technical reasoning skills.

---

## Persistence Value

Despite multiple technical roadblocks, pushing through challenges resulted in significant growth and a functioning application.

---

## Technical Stretching

Working with multiple unfamiliar technologies simultaneously created a steep learning curve — but ultimately delivered broader skills and a deeper understanding of the iOS ecosystem.  
I recognize that frameworks like Natural Language will require multiple projects to master fully.

---

## Future Directions

This project sparked a strong interest in further exploring Natural Language processing on iOS.  
I’m also excited to work with Apple's pre-built CoreML models to gain more experience with machine learning integration in a more structured & simplified context.

---

## Conclusion

Building this app stretched my technical abilities in meaningful ways.  
The process reinforced that stepping outside your comfort zone — even at the cost of mistakes — is essential for growth as a developer.  
While the path wasn’t always smooth, the resulting application demonstrates the power of combining SwiftUI with Apple's advanced frameworks to create a practical, intelligent tool for users.

---
