# Brief

**Brief** is an iOS app designed to simplify how users save and engage with articles. By leveraging Apple’s native frameworks like **Core ML**, **Natural Language**, and **SiriKit**, Brief aims to provide concise summaries of saved content, along with a simple, intuitive note-taking experience.

This project is both a personal challenge and a learning journey. Inspired by tutorials like Peter Friese’s [Second Brain](https://youtube.com/playlist?list=PLsnLd2esiGRTmfGZcZMnEy6hkBHXBH_en&si=gOZhnR84skKJpUBb) app, I decided to take a different route, focusing on Apple’s native stack to create an app that feels deeply integrated into the ecosystem. While this might push the limits of my current skills, it’s a journey I’m excited to share.

Whether successful or not, I hope this project serves as a source of learning and inspiration for others.

---

## Features

- **Save Articles**: Users can save articles from Safari or other apps directly into Brief.
- **Article Summaries**: Using Apple's **Natural Language** and **Core ML** frameworks, Brief aims to summarize saved articles to provide concise and meaningful insights.
- **Note-Taking**: A built-in feature allowing users to jot down thoughts or insights while reading.
- **Voice Integration**: Exploring the potential of **SiriKit** to enable users to ask Siri for a summary of saved articles.

---

## Challenges and Goals

I recognize that building an app of this complexity isn’t easy, especially with the goal of using Apple’s frameworks as natively as possible. However, I’m excited to explore the following:

1. Integrating **Share Extensions** to allow users to save articles from Safari into the app.
2. Using **Natural Language Processing (NLP)** for article summarization.
3. Implementing a seamless user experience for note-taking.
4. Experimenting with **SiriKit** to bring voice-powered summaries to life.

While there’s no guarantee of success, I believe in learning through the process and iterating on what works.

---

## Why Native?

There are countless tools and libraries available, but I want Brief to feel deeply integrated into the Apple ecosystem. By leveraging native frameworks like **Core ML**, **Natural Language**, and **SiriKit**, I hope to create an app that feels seamless and intuitive for iOS users while challenging myself to grow as a developer.

---

## Acknowledgments

This project draws inspiration from the work of developers like Peter Friese, whose tutorials and insights encouraged me to take on this challenge. While I chose a different approach, I’m grateful for the ideas that sparked this journey.

Thanks also to the Apple Developer documentation and community resources, which have been invaluable in navigating unfamiliar territory.

---

## Current Progress

- [x] Basic app structure and Share Extension for saving articles.
- [x] Initial UI for displaying saved articles.
- [ ] taking notes.
- [ ] Implementing article summarization with **Natural Language**.
- [ ] Exploring Siri integration for voice-driven summaries.

--- 

### ⚡ How to Use This Notebook
- Running this notebook **generates a Core ML file using pretrained data**: `distilbert_classification.mlpackage`.
- **Other pretrained models may be better suited to your needs.**  
  If you choose to use a different model, simply rename the model name where applicable.
- After running the notebook, **move the generated model file** to your `Model` folder.


🔗 **[View the notebook in GitHub](https://github.com/RachelRadford21/Brief/blob/main/Brief/HelperFiles/Services/BriefColabNotebook.ipynb)**

### ⚠️ **GitHub File Size Limitations**
The generated model file is **too large to be pushed directly to GitHub**.  
If you need to include it in version control, consider:
- **[Git Large File Storage (LFS)](https://git-lfs.github.com/)** – A Git extension designed for tracking large files.

- **Adding it to `.gitignore`** to exclude it from Git:
  ```plaintext
  distilbert_classification.mlpackage

---

## License

This project is open-source and available under the [MIT License](License).
