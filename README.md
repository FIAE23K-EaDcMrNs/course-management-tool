# course_management-tool

## Unser Team
- **Emmanuel Atisu** - Projektleiter, Koordination, Containerisierung und Deployment, außerdem Virtuose im Programmieren und Debuggen
- **Maximilian Riekenberg** - Co-Projektleiter, Backend, Wiki und allgemein die gute Seele des Teams
- **Siko Norge** - Frontend-Entwickler, UI/UX Design und die kreative Ader des Teams
- **Dean Clark** - Frontend-Entwickler und zuständig für alles schriftliche(Exposé, Readme etc.)

## Unsere Dokumentation und das Wiki
Für die ausführliche Dokumentation unseres Projekts, besuchen Sie bitte unser [Wiki](https://github.com/FIAE23K-EaDcMrNs/course-management-tool/wiki)

## Kanban-Projektmanagement
Unser Projektmanagement erfolgt über ein Kanban-Board, das Sie unter folgendem Link finden:
[Kanban Board](https://github.com/orgs/FIAE23K-EaDcMrNs/projects/4)

## Quickstart Guide via Docker
1. **Repository klonen**:
   ```bash
   git clone
   ```

2. **In das Verzeichnis wechseln**:
   ```bash
   cd course_management-tool
   ```

3. **Abhängigkeiten installieren**:
   ```bash
    docker-compose up -d
    ```
**Where to access the application**:
- Frontend: `http://localhost:8080`
- Backend: `http://localhost:8081`
- Datenbank: http://localhost:5500 oder http://localhost:1521
- ORDS: http://localhost:8181
- Ollama: http://localhost:11434

## Quickstart Guide via Makefile
1. **Repository klonen**:
   ```bash
   git clone
   ```
2. **In das Verzeichnis wechseln**:
   ```bash
   cd course-management-tool
    ```
3. **Makefile Befehle**:
   - **Build**: Startet die Docker-Dev-Container
     ```bash
     make docker-up-dev
     ```
   - **Start**: Startet die Docker-Prod-Container
     ```bash
     make docker-up-prod
     ```
   - **Stop**: Stoppt die Docker-Container
     ```bash
     make docker-down
     ```
