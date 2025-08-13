const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const cors = require('cors');
const bodyParser = require('body-parser');
const fs = require('fs').promises;
const path = require('path');

dotenv.config();

const app = express();
app.use(cors());
app.use(bodyParser.json());

// Connect to MongoDB (with fallback)
if (process.env.MONGO_URI) {
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log('MongoDB connected'))
  .catch(err => console.error('MongoDB connection error:', err));
} else {
  console.log('⚠️  MONGO_URI not found in .env file. Server running without database.');
  console.log('📝 Create a .env file in the server directory with MONGO_URI=mongodb://localhost:27017/emotion_journal');
}

// Ensure data directory exists
const dataDir = path.join(__dirname, '../data');
const ensureDataDir = async () => {
  try {
    await fs.access(dataDir);
  } catch {
    await fs.mkdir(dataDir, { recursive: true });
  }
};

// Initialize data directory
ensureDataDir();

// Helper function to save sentiment analysis response
const saveSentimentResponse = async (date, sentimentData) => {
  const filename = `${date}.json`;
  const filepath = path.join(dataDir, filename);
  await fs.writeFile(filepath, JSON.stringify(sentimentData, null, 2));
  console.log(`Sentiment data saved for ${date}: ${filepath}`);
};

// Helper function to get sentiment data for a date
const getSentimentData = async (date) => {
  try {
    const filename = `${date}.json`;
    const filepath = path.join(dataDir, filename);
    const data = await fs.readFile(filepath, 'utf8');
    return JSON.parse(data);
  } catch (error) {
    return null;
  }
};

// Helper function to calculate mood breakdown from sentiment scores
const calculateMoodBreakdown = (scores) => {
  // Map sentiment scores to mood categories
  const moodMapping = {
    joy: 'Happy',
    love: 'Content', 
    surprise: 'Excited',
    fear: 'Anxious',
    anger: 'Frustrated',
    sadness: 'Sad'
  };

  // Convert scores to 0-4 scale and create mood breakdown
  const moodBreakdown = {};
  Object.keys(scores).forEach(sentiment => {
    const mood = moodMapping[sentiment] || sentiment;
    // Convert -1 to 1 range to 0 to 4 range
    const normalizedScore = Math.max(0, Math.min(4, (scores[sentiment] + 1) * 2));
    moodBreakdown[mood] = normalizedScore;
  });

  return moodBreakdown;
};

// Helper function to calculate average mood score
const calculateAverageMood = (scores) => {
  const values = Object.values(scores);
  const average = values.reduce((sum, val) => sum + val, 0) / values.length;
  // Convert to 0-10 scale
  const normalizedAverage = (average / 4) * 10;
  
  let moodLabel = 'Neutral';
  if (normalizedAverage >= 8) moodLabel = 'Excellent';
  else if (normalizedAverage >= 6) moodLabel = 'Good';
  else if (normalizedAverage >= 4) moodLabel = 'Okay';
  else if (normalizedAverage >= 2) moodLabel = 'Poor';
  else moodLabel = 'Very Poor';

  return {
    score: normalizedAverage.toFixed(1),
    label: moodLabel
  };
};

// Helper function to get emoji based on top sentiment
const getEmojiForSentiment = (topLabel) => {
  const emojiMap = {
    joy: '😊',
    love: '😌',
    surprise: '🤩',
    fear: '😰',
    anger: '😡',
    sadness: '😢'
  };
  return emojiMap[topLabel] || '😐';
};

// API Routes

// Sentiment Analysis endpoint
app.post('/api/sentiment-analysis', async (req, res) => {
  try {
    const { text, date } = req.body;
    
    if (!text || !date) {
      return res.status(400).json({ error: 'Text and date are required' });
    }

    // This is where you would call your actual sentiment analysis API
    // For now, I'll simulate the API response you provided
    const sentimentResponse = {
      scores: {
        sadness: -0.03000987134873867,
        joy: 0.09970700740814209,
        love: 0.12099681049585342,
        anger: -0.10828430950641632,
        fear: 0.24226462841033936,
        surprise: 0.125854030251503
      },
      top_label: "fear",
      top_score: 0.24226462841033936
    };

    // Save the sentiment response to JSON file
    await saveSentimentResponse(date, sentimentResponse);

    // Calculate mood breakdown and average mood
    const moodBreakdown = calculateMoodBreakdown(sentimentResponse.scores);
    const averageMood = calculateAverageMood(sentimentResponse.scores);
    const emoji = getEmojiForSentiment(sentimentResponse.top_label);

    res.json({
      success: true,
      sentiment: sentimentResponse,
      moodBreakdown,
      averageMood,
      emoji
    });

  } catch (error) {
    console.error('Sentiment analysis error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get journal entry for a specific date
app.get('/api/journal/:date', async (req, res) => {
  try {
    const { date } = req.params;
    const sentimentData = await getSentimentData(date);
    
    if (!sentimentData) {
      return res.json({ exists: false });
    }

    const moodBreakdown = calculateMoodBreakdown(sentimentData.scores);
    const averageMood = calculateAverageMood(sentimentData.scores);
    const emoji = getEmojiForSentiment(sentimentData.top_label);

    res.json({
      exists: true,
      sentiment: sentimentData,
      moodBreakdown,
      averageMood,
      emoji
    });

  } catch (error) {
    console.error('Get journal error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get all journal entries (for calendar)
app.get('/api/journal', async (req, res) => {
  try {
    const files = await fs.readdir(dataDir);
    const entries = {};
    
    for (const file of files) {
      if (file.endsWith('.json')) {
        const date = file.replace('.json', '');
        const sentimentData = await getSentimentData(date);
        if (sentimentData) {
          const emoji = getEmojiForSentiment(sentimentData.top_label);
          entries[date] = {
            emoji,
            topLabel: sentimentData.top_label,
            topScore: sentimentData.top_score
          };
        }
      }
    }

    res.json(entries);

  } catch (error) {
    console.error('Get all journals error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'Server is running' });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));