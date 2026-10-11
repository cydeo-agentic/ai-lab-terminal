# CYDEO AI Lab · terminal

Your own Linux terminal in the browser, with **cydeo**, the CYDEO AI Lab agent, ready to use. It also has Java 21 and Maven. Nothing to install on your laptop, and it works on any computer with Chrome.

## Start (first time, about 3 minutes)

1. **[Open the AI Lab terminal](https://codespaces.new/cydeo-agentic/ai-lab-terminal?quickstart=1)**, sign in to GitHub, and click **Create codespace**.
2. When the terminal says **Setup finished**, type:
   ```bash
   cydeo login
   ```
   Approve in the browser tab that opens, signing in with your CYDEO account. Wait for `Logged in.`
3. Type:
   ```bash
   cydeo
   ```
   Now talk to your agent.

Next time, open the same link. It takes you back to your Codespace, where you are already signed in.

## Try these

Start `cydeo` inside the practice project (`cd practice`, then `cydeo`). Paste one at a time:

- `Explain what BankAccount.java does, line by line, like I am new to Java.`
- `Write JUnit 5 tests for withdraw(), including the edge cases. Then run mvn test and show me the result.`
- `One of your tests should fail. Is the bug in the test or in BankAccount? Prove it with the test output.`
- `Fix the bug, run mvn test again, and show me that every test passes.`

**The rule:** the agent's "it works" is a claim. `mvn test` is the proof. Always ask it to run the test and show you the output.

## Good to know

- **Your AI budget:** see it at [ai.cydeo.com](https://ai.cydeo.com) after you sign in.
- **Free hours:** GitHub gives you 60 hours a month on this 2-core machine. When you are done, stop the Codespace: **Codespaces** menu (bottom-left corner) → **Stop Current Codespace**. It also stops by itself after 30 minutes idle.
- **Your GitHub username:** after you sign in with `cydeo login`, this Codespace tells CYDEO which GitHub account you use, so your instructors can find your work.
- **Keep your work:** files in this Codespace stay until you delete the Codespace. To keep something forever, copy it into your own GitHub repository.
- **Stuck?**
  - `cydeo` says you are not logged in: run `cydeo login` again.
  - Approval says you are not eligible: post in your class thread with the email you use for CYDEO.
