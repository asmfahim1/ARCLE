import 'package:arcle/src/state_management.dart';
import 'package:arcle/src/templates/ai/agent_templates.dart';
import 'package:arcle/src/templates/ai/claude_templates.dart';
import 'package:arcle/src/templates/ai/codex_templates.dart';
import 'package:arcle/src/templates/ai/gemini_templates.dart';
import 'package:test/test.dart';

void main() {
  group('CodexTemplates', () {
    test('codexMd generates CODEX.md with mandatory workflow sections', () {
      final content = CodexTemplates.codexMd('my_app', StateManagement.bloc);
      expect(
        content,
        contains('# CODEX.md — Mandatory ARCLE Development Workflow Rules'),
      );
      expect(content, contains('## 1. Mandatory Shared Rule Loading'));
      expect(content, contains('.ai/project-context.md'));
      expect(content, contains('.ai/architecture-rules.md'));
      expect(content, contains('.ai/coding-rules.md'));
      expect(content, contains('.ai/security-rules.md'));
      expect(content, contains('## 2. Project Discovery & Context'));
      expect(content, contains('git status --short --branch'));
      expect(content, contains('docs/PLAN.md'));
      expect(content, contains('docs/HISTORY.md'));
      expect(content, contains('## 3. Task Planning'));
      expect(content, contains('## 4. UI & Design System'));
      expect(content, contains('Investigate ARCLE Core Elements First'));
      expect(content, contains('CommonDropdown'));
      expect(content, contains('CommonTextField'));
      expect(content, contains('CommonCheckbox'));
      expect(content, contains('CommonButton'));
      expect(content, contains('Permission Gate for New External Packages'));
      expect(content, contains('Dimensions'));
      expect(content, contains('AppColors'));
      expect(content, contains('## 5. Clean Architecture Standards'));
      expect(content, contains('Presentation → Domain ← Data'));
      expect(content, contains('## 6. Coding & Security Standards'));
      expect(content, contains('Logger'));
      expect(content, contains('SessionManager'));
      expect(content, contains('## 7. Verification'));
      expect(content, contains('dart format .'));
      expect(content, contains('flutter analyze'));
      expect(content, contains('flutter test'));
      expect(content, contains('PASS'));
      expect(content, contains('FAIL'));
      expect(content, contains('## 8. Work Tracking & History'));
      expect(content, contains('arcle history add'));
      expect(content, contains('--agent codex'));
      expect(content, contains('## 9. Agent Switching & Continuation'));
      expect(content, contains('## 10. Completion Report'));
    });

    test('instructionsMd legacy alias forwards to codexMd', () {
      final legacy = CodexTemplates.instructionsMd(
        'my_app',
        StateManagement.bloc,
      );
      final modern = CodexTemplates.codexMd('my_app', StateManagement.bloc);
      expect(legacy, equals(modern));
    });

    test('codexSettings includes .codex/CODEX.md in context_files', () {
      final settings = CodexTemplates.codexSettings(StateManagement.bloc);
      expect(settings, contains('.codex/CODEX.md'));
      expect(settings, contains('.ai/settings.yaml'));
      expect(settings, contains('.ai/project-context.md'));
      expect(settings, contains('.ai/architecture-rules.md'));
      expect(settings, contains('.ai/coding-rules.md'));
      expect(settings, contains('.ai/security-rules.md'));
    });
  });

  group('ClaudeTemplates', () {
    test('claudeMd generates CLAUDE.md with mandatory workflow sections', () {
      final content = ClaudeTemplates.claudeMd('my_app', StateManagement.bloc);
      expect(
        content,
        contains('# CLAUDE.md — Mandatory ARCLE Development Workflow Rules'),
      );
      expect(content, contains('## 1. Mandatory Shared Rule Loading'));
      expect(content, contains('.ai/project-context.md'));
      expect(content, contains('.ai/architecture-rules.md'));
      expect(content, contains('.ai/coding-rules.md'));
      expect(content, contains('.ai/security-rules.md'));
      expect(content, contains('## 3. Key Commands'));
      expect(content, contains('Investigate ARCLE Core Elements First'));
      expect(content, contains('Permission Gate for New External Packages'));
      expect(content, contains('flutter run'));
      expect(content, contains('arcle verify --full'));
      expect(content, contains('Dimensions'));
      expect(content, contains('AppColors'));
      expect(content, contains('Presentation → Domain ← Data'));
      expect(content, contains('arcle history add'));
      expect(content, contains('--agent claude'));
      expect(content, contains('## 12. Claude Preferences'));
    });

    test(
      'claudeSettings contains standard permissions and arcle history allowlist',
      () {
        final settings = ClaudeTemplates.claudeSettings();
        expect(settings, contains('Bash(arcle history add*)'));
        expect(settings, contains('Bash(flutter analyze)'));
      },
    );
  });

  group('GeminiTemplates', () {
    test('geminiMd generates GEMINI.md with mandatory workflow sections', () {
      final content = GeminiTemplates.geminiMd('my_app', StateManagement.bloc);
      expect(
        content,
        contains('# GEMINI.md — Mandatory ARCLE Development Workflow Rules'),
      );
      expect(content, contains('## 1. Mandatory Shared Rule Loading'));
      expect(content, contains('.ai/project-context.md'));
      expect(content, contains('.ai/architecture-rules.md'));
      expect(content, contains('.ai/coding-rules.md'));
      expect(content, contains('.ai/security-rules.md'));
      expect(content, contains('Investigate ARCLE Core Elements First'));
      expect(content, contains('Permission Gate for New External Packages'));
      expect(content, contains('Dimensions'));
      expect(content, contains('AppColors'));
      expect(content, contains('Presentation → Domain ← Data'));
      expect(content, contains('arcle history add'));
      expect(content, contains('--agent gemini'));
      expect(content, contains('## 9. Agent Switching & Continuation'));
      expect(content, contains('## 10. Completion Report'));
    });

    test('geminiSettings includes .gemini/GEMINI.md in context_files', () {
      final settings = GeminiTemplates.geminiSettings(StateManagement.bloc);
      expect(settings, contains('.gemini/GEMINI.md'));
      expect(settings, contains('.ai/project-context.md'));
      expect(settings, contains('.ai/architecture-rules.md'));
    });
  });

  group('AgentTemplates (Shared .ai/ rules)', () {
    test('projectContext includes mandatory workflow and agent switching', () {
      final context = AgentTemplates.projectContext(
        'my_app',
        StateManagement.bloc,
      );
      expect(context, contains('## Mandatory Workflow for AI Agents'));
      expect(context, contains('Context & Discovery'));
      expect(context, contains('Task Planning'));
      expect(context, contains('Verification'));
      expect(context, contains('Work Tracking'));
      expect(context, contains('Agent Switching'));
      expect(context, contains('Completion Report'));
    });

    test(
      'architectureRules includes focused use cases and model/entity separation',
      () {
        final arch = AgentTemplates.architectureRules(StateManagement.bloc);
        expect(arch, contains('Presentation → Domain ← Data'));
        expect(arch, contains('Focused Use Cases'));
        expect(arch, contains('Model vs Entity Separation'));
        expect(arch, contains('Independent Lifecycles'));
      },
    );

    test(
      'codingRules includes UI & design system rules and verification standards',
      () {
        final coding = AgentTemplates.codingRules(StateManagement.bloc);
        expect(coding, contains('## UI & Design System'));
        expect(coding, contains('Investigate ARCLE Core Elements First'));
        expect(coding, contains('CommonDropdown'));
        expect(coding, contains('Permission Gate for New External Packages'));
        expect(coding, contains('common_widgets'));
        expect(coding, contains('Dimensions Utility'));
        expect(coding, contains('Figma & Visual References'));
        expect(coding, contains('## Verification & Quality Standards'));
        expect(coding, contains('dart format .'));
        expect(coding, contains('flutter analyze'));
        expect(coding, contains('flutter test'));
        expect(coding, contains('PASS'));
        expect(coding, contains('FAIL'));
        expect(coding, contains('SKIPPED'));
        expect(coding, contains('NOT RUN'));
      },
    );
  });
}
