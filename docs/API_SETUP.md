# OMDB API Setup Guide

## Getting Your API Key

1. **Visit OMDB API**: Go to [https://www.omdbapi.com/apikey.aspx](https://www.omdbapi.com/apikey.aspx)

2. **Choose a Plan**:

   - **FREE** (1,000 daily limit) - Perfect for development
   - **Patron** ($1-$5/month) - Higher limits for production

3. **Register**: Fill out the form with your email

4. **Verify**: Check your email and click the activation link

5. **Get Your Key**: You'll receive your API key via email

## Setting Up Your API Key

### For Development (Recommended)

1. **Create a Configuration File**:

   ```bash
   cd filmz2
   touch filmz2/Config/APIKeys.swift
   ```

2. **Add to `.gitignore`** (IMPORTANT!):

   ```bash
   echo "filmz2/Config/APIKeys.swift" >> .gitignore
   ```

3. **Create the Configuration**:

   ```swift
   // filmz2/Config/APIKeys.swift
   struct APIKeys {
       static let omdbAPIKey = "YOUR_API_KEY_HERE"
   }
   ```

### Alternative: Environment Variables

1. **Set in Xcode**:

   - Edit Scheme → Run → Arguments
   - Add Environment Variable: `OMDB_API_KEY` = `your-key-here`

2. **Or in Terminal**:

   ```bash
   export OMDB_API_KEY="your-key-here"
   ```

## Using the API Key in Code

```swift
// In your app initialization or service creation
let apiKey = APIKeys.omdbAPIKey // If using config file
// OR
let apiKey = ProcessInfo.processInfo.environment["OMDB_API_KEY"] ?? ""

let searchService = OMDBSearchService(apiKey: apiKey)
```

## Security Best Practices

1. **NEVER commit API keys** to version control
2. **Use environment variables** for CI/CD
3. **Rotate keys regularly** if exposed
4. **Monitor usage** in OMDB dashboard

## Troubleshooting

- **"Invalid API key!"**: Check key is correctly copied
- **"Request limit reached"**: Wait until next day (resets at UTC midnight)
- **No response**: Verify internet connection and HTTPS is used

## Example .gitignore Entry

```gitignore
# API Keys - NEVER COMMIT
filmz2/Config/APIKeys.swift
*.apikeys
.env
```
