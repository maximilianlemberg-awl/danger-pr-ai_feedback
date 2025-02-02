# danger-ai_feedback

A Danger plugin that analyzes GitLab pipelines for failed jobs and provides AI-generated feedback using OpenAI.

## Installation

```sh
$ gem install danger-ai_feedback
```

## Usage

Methods and attributes from this plugin are available in your `Dangerfile` under the `ai_feedback` namespace.

### Example Usage in a `Dangerfile`

```ruby
ai_feedback.analyze_pipeline
```

### Environment Variables
To use this plugin, you need to set the following environment variables:

- `GITLAB_API_TOKEN` – Your GitLab API token.
- `CI_API_V4_URL` – The GitLab API base URL.
- `CI_PROJECT_ID` – The project ID in GitLab.
- `OPENAI_API_KEY` – Your OpenAI API key.

### How It Works
1. The plugin retrieves the latest GitLab pipeline.
2. It checks for failed jobs and extracts the last 100 lines of each job’s log.
3. It sends the logs to OpenAI for analysis.
4. The AI-generated feedback is output as a Danger message or warning.

### Example Output

If a pipeline contains failed jobs, Danger will post a message like:

```
🚨 Failing Pipeline detected

**Job: build-test**
❌ Error Details:
<error log snippet>

🔍 Root Cause:
- Possible issue with dependency installation.

🛠 Suggested Fix:
```bash
bundle install --retry 3
```

_Automatically generated with OpenAI. This is only a suggestion and can be wrong._
```

### Contributing
Feel free to open issues or submit PRs to improve the plugin!

## License

This project is licensed under the MIT License.


## Development

1. Clone this repo
2. Run `bundle install` to setup dependencies.
3. Run `bundle exec rake spec` to run the tests.
4. Use `bundle exec guard` to automatically have tests run as you make changes.
5. Make your changes.
