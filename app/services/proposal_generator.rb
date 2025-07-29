# app/services/proposal_generator.rb
class ProposalGenerator
    def self.generate(description:, user:, addresse:)
      client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
  
      response = client.chat(
        parameters: {
          model: "gpt-4",
          messages: [
            { role: "system", content: "You write effective freelance job proposals for UpWork." },
            { role: "user", content: "Write a proposal addressed to #{addresse} from #{user.full_name}. #{user.full_name} has the following work experience '#{user.work_experience}' and is applying for the following job '#{description}'. Keep the proposal under 200 words to be in line with UpWork requirements." }
          ],
          temperature: 0.7
        }
      )
  
      response.dig("choices", 0, "message", "content")
    rescue => e
      Rails.logger.error("OpenAI error: #{e.message}")
      nil
    end
end
  