# MediCortex

**MediCortex** is an AI-driven biomedical search assistant designed to help clinicians, researchers, and students extract high-quality scientific information from PubMed more efficiently and intuitively. By combining a fine-tuned BERT model with a robust mobile and backend architecture, MediCortex bridges the gap between natural-language questions and precise, metadata-enriched PubMed queries.

## 🧠 Core Concept

At the heart of MediCortex lies a custom-trained BERT-based multi-label classifier that maps free-form clinical questions to:

- **MeSH terms** (Medical Subject Headings)
- **Authors**
- **Temporal intervals (time constraints)**

This allows users to input open-ended queries such as:  
*"What are recent treatments for glioblastoma in children?"*  
and receive structured, targeted PubMed results enriched with semantic metadata.

## 🚀 Features

- **AI-Powered NLP**: Fine-tuned BioBERT model trained on a manually annotated dataset of biomedical questions and article metadata.
- **Custom Dataset**: Includes over 1,500 labeled examples with MeSH terms, authorship, and time tags for training and evaluation.
- **Smart PubMed Queries**: Automatically constructs advanced queries based on predicted metadata to improve precision and recall.
- **Mobile-First Experience**: A modern, intuitive native iOS application built in Swift with Combine, allowing real-time querying and result visualization.
- **Scalable Backend**: Django + TensorFlow API that handles inference and article search logic via PubMed's E-Utilities.

## 🔧 Technologies Used

- **NLP & AI**: BioBERT, HuggingFace Transformers, PyTorch, TensorFlow
- **Backend**: Django, Django REST Framework
- **iOS App**: Swift, Combine, UIKit
- **Integration**: Entrez E-Utilities API for PubMed access

## 🧪 Project Motivation

Medical professionals often rely on PubMed, but crafting effective queries requires knowledge of MeSH terms and search syntax. MediCortex simplifies this process using modern natural language understanding, reducing cognitive load and improving research efficiency.

## 📱 Mobile Client

The iOS app features:

- Clean, responsive UI
- Live query preview
- Auto-tagging with predicted MeSH terms
- Scrollable and filterable PubMed result list
- Native sharing and export support

## 📡 Backend API

The Django-based API

## 👨‍🎓 Academic Context

This project was developed as part of a Bachelor's thesis in Artificial Intelligence (2024). It combines techniques from deep learning, biomedical informatics, and mobile development into a unified research tool.

**Note:** This is a proof-of-concept research tool and should not be used for clinical decision-making without further validation.

