# JDCode

This repository provides docker containers configured to run VSCode and Opencode.

## Variants

There are custom configurations for specific development environments, such as TypeScript and Python. Each variant has predefined extensions, settings, and tools tailored to the respective programming environment.

### 1️⃣ **jdcode-python**
- Includes:
  - `ms-python.python` extension for Python development (test running/play button enabled).
  - Python development tools, such as `flake8`, `autopep8`, and `mypy`.
  - `eamodio.gitlens` for Git blame and enhanced Git capabilities.
  - Configured keyboard shortcuts:
    - **Command/Control + U**: Expand selection.
    - **Shift + Command/Control + U**: Contract selection.

### 2️⃣ **jdcode-ts**
- Includes:
  - TypeScript-related extensions: `dbaeumer.vscode-eslint`, `esbenp.prettier-vscode`, and `ms-vscode.vscode-typescript-tslint-plugin`.
  - `ms-vscode.vscode-jest`, configured to work with Vitest (requires setup, see below).
  - `eamodio.gitlens` for Git blame and enhanced Git capabilities.
  - Configured keyboard shortcuts:
    - **Command/Control + U**: Expand selection.
    - **Shift + Command/Control + U**: Contract selection.

---

## 🛠️ How to Build the Containers

To build the Docker images for each variant, use the `build.sh` script.

1. Navigate to the `docker` directory:
   ```bash
   cd docker
   ```

2. Build a specific variant. For example:
   ```bash
   ./build.sh python
   ./build.sh ts
   ```

This will create Docker images tagged as `jdcode-python` and `jdcode-ts`.

## 🌍 How to Use the Docker Containers

> Note: Binding ports in docker uses the -p flag in the form HOST_PORT:CONTAINER_PORT

1. **Run the containers**:
   Start each environment by binding the appropriate port:
   - For Python:
     ```bash
     docker run -it -v "$PWD":/code -p 8080:8080 jdcode-python
     ```
   - For TypeScript:
     ```bash
     docker run -it -v "$PWD":/code -p 8080:8080 jdcode-ts
     ```

3. **Access the VSCode instance**:
   - Open your browser to `http://localhost:8080`

4. **Access Opencode**
   - In your container, execute `opencode`

---

## 🔗 Creating Aliases for Convenience

To avoid typing long docker commands, you can create shell aliases:

### Bash/Zsh

Add these lines to your `~/.bashrc` or `~/.zshrc`:

```bash
alias jdcode-python='docker run -it --rm -v "$PWD":/code -p 8080:8080 jdcode-python'
alias jdcode-ts='docker run -it --rm -v "$PWD":/code -p 8080:8080 jdcode-ts'
```

Then reload your shell configuration:
```bash
source ~/.bashrc  # or source ~/.zshrc
```

### Usage

After setting up the aliases, you can simply run:
```bash
jdcode-python   # Start Python development environment
jdcode-ts       # Start TypeScript development environment
```

---

## ⚙️ Notes for Testing Play Buttons with Vitest (for the TypeScript Variant)

The `ms-vscode.vscode-jest` extension can be made to work with Vitest:

1. Update your `package.json` to alias Jest commands to Vitest:
   ```json
   {
     "scripts": {
       "test": "vitest",
       "test:watch": "vitest --watch",
       "test:coverage": "vitest --coverage",
       "jest": "vitest",
       "jest:watch": "vitest --watch"
     }
   }
   ```

2. Configure VSCode to use the `npm test --` command for the play button (already in the `settings.json`):
   ```json
   {
     "jest.jestCommandLine": "npm test --"
   }
   ```

For more details, refer to the official [Vitest Documentation](https://vitest.dev/).
