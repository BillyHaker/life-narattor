# Life Narrator - Documentation Index

**Version**: 1.0
**Last Updated**: 2026-03-06
**Status**: Production-ready core features, active development

---

## 📖 Reading Guides

### For New Team Members
1. **Quick Start Guide** (10 min) - `快速入门指南.md` (Chinese)
2. **Complete Onboarding** (2-3 hours) - `ONBOARDING_GUIDE.md` (Chinese)
3. **This Index** - Overview of all documentation

### Reading Order Priority
- **P0 (Critical)** - Must read before starting work
- **P1 (Important)** - Should read within first week
- **P2 (Useful)** - Read as needed

---

## 📁 Documentation Structure

```
Life Narattor/
│
├── Root-Level Documents (Latest Work)
│   ├── ONBOARDING_GUIDE.md           [P0] Complete team onboarding
│   ├── 快速入门指南.md                [P0] Quick start (Chinese)
│   ├── DOCUMENTATION_INDEX.md         [P0] This file
│   ├── README.md                      [P0] Project overview
│   ├── THREADING_FIX_FINAL.md        [P0] Latest fix - UI freeze
│   ├── COMPLIANCE_FIX_SUMMARY.md     [P1] Privacy compliance fixes
│   ├── URGENT_FIX_DETAIL_FREEZE.md   [P1] Freeze issue diagnosis
│   ├── FREEZE_DIAGNOSIS.md           [P2] Input freeze diagnosis
│   └── MANUAL_TEST_CHECKLIST.md      [P1] Manual testing guide
│
├── Rules/ (Development Standards)
│   ├── AI_RULES.md                   [P0] Core AI development rules
│   ├── DEV_LOG_RULES.md              [P0] Documentation standards
│   ├── WORKFLOW.md                   [P0] Standard development flow
│   ├── CONTEXT.md                    [P1] Context management
│   ├── PLAN_TEMPLATE.md              [P2] Planning template
│   ├── TDD_GUIDE.md                  [P1] Test-driven development
│   ├── REVIEW_CHECKLIST.md           [P1] Code review checklist
│   └── SECURITY.md                   [P1] Security baseline
│
├── Templates/ (Document Templates)
│   ├── SESSION_LOG_TEMPLATE.md       [P0] Session log template
│   ├── ADR_TEMPLATE.md               [P1] Architecture decision template
│   ├── CHANGELOG_TEMPLATE.md         [P0] Change log template
│   └── HANDOVER_TEMPLATE.md          [P2] Handover template
│
├── Skills/ (Feature Specifications)
│   ├── SKILLS_INDEX.md               [P0] Skills overview
│   │
│   ├── Product & Design
│   │   ├── product-northstar/        [P0] Product positioning
│   │   ├── user-scenarios/           [P0] User scenarios
│   │   ├── ia-navigation/            [P1] Information architecture
│   │   ├── ui-pattern-library/       [P2] UI component library
│   │   └── accessibility-guidelines/ [P2] Accessibility standards
│   │
│   ├── Core Technology
│   │   ├── database-schema/          [P0] Database design (Core Data)
│   │   ├── ai-interaction/           [P0] AI service integration
│   │   ├── atomization/              [P0] Auto-split feature
│   │   ├── tags/                     [P0] Tag system
│   │   ├── clean-defiller/           [P1] Text cleaning
│   │   └── speech-transcription/     [P1] Voice transcription
│   │
│   ├── Features
│   │   ├── capture-ui/               [P1] Capture interface
│   │   ├── assist-archive-card/      [P2] Archive cards
│   │   ├── daily-narrative-two-layer/[P2] Daily narrative
│   │   ├── timeline-browse/          [P1] Timeline browsing
│   │   ├── review-memory/            [P2] Review system
│   │   ├── project-review/           [P2] Project review
│   │   └── search/                   [P1] Search functionality
│   │
│   ├── Developer Tools
│   │   ├── devtools-debug-suite/     [P0] Debug tools
│   │   ├── privacy-redaction-standard/[P0] Privacy protection
│   │   ├── dev-logging-system/       [P1] Logging system
│   │   └── feature-flags-governance/ [P2] Feature flags
│   │
│   └── Quality & Process
│       ├── acceptance-testing-min-bar/[P1] Acceptance testing
│       ├── ci-and-quality-assurance/ [P2] CI/CD
│       ├── contract-versioning/      [P2] API versioning
│       └── data-governance-and-compliance/[P1] Data compliance
│
└── Docs/ (Project Documentation)
    ├── 00_Index/                     Documentation setup
    ├── 01_Product/                   Product documentation
    │   └── Placeholder_Features.md   [P0] Feature list & status
    ├── 02_Architecture/              Architecture docs
    ├── 03_Decisions/                 Architecture Decision Records
    │   ├── ADR-001-coredata-v1.md    [P0] Core Data architecture
    │   ├── ADR-001-privacy-redaction-architecture.md [P0] Privacy arch
    │   ├── ADR-004-atom-tag-coredata.md [P1] Atom/Tag relationships
    │   ├── ADR-007-openai-client-key-dev-only.md [P1] OpenAI config
    │   ├── ADR-008-backend-proxy-for-ai.md [P1] Backend proxy
    │   └── ... (9 ADRs total)
    ├── 04_Sessions/                  Work session logs
    │   ├── 2026-03-06_session-001.md [P0] Latest session
    │   └── ... (46 sessions total)
    ├── 05_Changes/                   Change logs
    │   ├── Change-001-atomization-compliance-fixes.md [P0] Compliance
    │   └── ... (48 changes total)
    ├── 06_Testing/                   Testing documentation
    └── 99_Handover/                  Handover documents
```

---

## 🎯 Quick Reference by Role

### For AI Developers (Starting New Task)
1. Read task description
2. Find related Skill: `Skills/SKILLS_INDEX.md`
3. Read complete Skill definition
4. Review related code files
5. Create Session Log: `Docs/04_Sessions/`
6. Implement according to Skill spec
7. Create Change Log: `Docs/05_Changes/`
8. Test and handover

**Must Follow**:
- `Rules/AI_RULES.md` - Core rules
- `Rules/DEV_LOG_RULES.md` - Documentation standards
- Skill specifications (exact implementation)

### For Product Managers
1. `Skills/product-northstar/SKILL.md` - Product vision
2. `Skills/user-scenarios/SKILL.md` - User flows
3. `Docs/01_Product/Placeholder_Features.md` - Feature status
4. `Docs/04_Sessions/` - Recent work logs

### For Architects
1. `Skills/database-schema/SKILL.md` - Data model
2. `Skills/ai-interaction/SKILL.md` - AI architecture
3. `Docs/03_Decisions/` - All ADRs
4. `Docs/02_Architecture/` - Architecture docs

### For QA Engineers
1. `MANUAL_TEST_CHECKLIST.md` - Test cases
2. `Skills/acceptance-testing-min-bar/SKILL.md` - Test standards
3. `Rules/TDD_GUIDE.md` - TDD workflow
4. Each Skill's "Acceptance Criteria" section

### For DevOps
1. `Skills/ci-and-quality-assurance/SKILL.md` - CI/CD
2. `Skills/feature-flags-governance/SKILL.md` - Feature flags
3. `Rules/SECURITY.md` - Security baseline

---

## 🔍 Find Documentation By Topic

### Understanding the Product
- **What is Life Narrator?** → `Skills/product-northstar/SKILL.md`
- **How do users use it?** → `Skills/user-scenarios/SKILL.md`
- **What features exist?** → `Docs/01_Product/Placeholder_Features.md`
- **UI/UX patterns** → `Skills/ui-pattern-library/SKILL.md`
- **Navigation structure** → `Skills/ia-navigation/SKILL.md`

### Understanding the Architecture
- **Database design** → `Skills/database-schema/SKILL.md` + `ADR-001-coredata-v1.md`
- **AI integration** → `Skills/ai-interaction/SKILL.md` + ADRs 007-009
- **Data flow** → `Skills/atomization/SKILL.md` + `Skills/tags/SKILL.md`
- **Privacy architecture** → `ADR-001-privacy-redaction-architecture.md`

### Understanding Core Features
- **Auto-split (Atomization)** → `Skills/atomization/SKILL.md`
- **Tag suggestions** → `Skills/tags/SKILL.md`
- **Text cleaning** → `Skills/clean-defiller/SKILL.md`
- **Voice transcription** → `Skills/speech-transcription/SKILL.md`
- **Capture UI** → `Skills/capture-ui/SKILL.md`
- **Timeline** → `Skills/timeline-browse/SKILL.md`
- **Search** → `Skills/search/SKILL.md`
- **Review** → `Skills/review-memory/SKILL.md` + `Skills/project-review/SKILL.md`

### Debugging & Development
- **How to debug?** → `Skills/devtools-debug-suite/SKILL.md`
- **Privacy protection** → `Skills/privacy-redaction-standard/SKILL.md`
- **Logging system** → `Skills/dev-logging-system/SKILL.md`
- **Feature flags** → `Skills/feature-flags-governance/SKILL.md`

### Recent Work & Fixes
- **Latest fix** → `THREADING_FIX_FINAL.md` (UI freeze)
- **Compliance fixes** → `COMPLIANCE_FIX_SUMMARY.md`
- **Recent sessions** → `Docs/04_Sessions/2026-03-06_session-001.md`
- **Recent changes** → `Docs/05_Changes/Change-048-*.md` (latest)

### Development Process
- **How to start?** → `Rules/WORKFLOW.md`
- **How to document?** → `Rules/DEV_LOG_RULES.md`
- **How to test?** → `Rules/TDD_GUIDE.md` + `MANUAL_TEST_CHECKLIST.md`
- **How to review?** → `Rules/REVIEW_CHECKLIST.md`
- **How to secure?** → `Rules/SECURITY.md`

---

## 📊 Document Statistics

### By Type
- **Rules**: 8 documents
- **Templates**: 4 documents
- **Skills**: 37 specifications
- **ADRs**: 9 decisions
- **Sessions**: 46 work logs
- **Changes**: 48 change logs
- **Root docs**: 8 documents

### By Priority
- **P0 (Critical)**: ~20 documents
- **P1 (Important)**: ~30 documents
- **P2 (Useful)**: ~40 documents

### Recent Activity
- **Last Session**: 2026-03-06
- **Last Change**: Change-048 (AI atomization debug)
- **Last ADR**: ADR-009 (AI atomization and tag suggestions)
- **Active Development**: Yes

---

## 🔄 Documentation Workflow

### Creating New Documentation

#### Session Log (Required for every work session)
1. **Template**: `Templates/SESSION_LOG_TEMPLATE.md`
2. **Location**: `Docs/04_Sessions/YYYY-MM-DD_session-NNN.md`
3. **Must Include**:
   - Goal
   - Plan
   - Work Log (chronological)
   - Decisions
   - Changes (references)
   - Verification
   - Next Steps
   - Handover Notes

#### Change Log (Required for every code change)
1. **Template**: `Templates/CHANGELOG_TEMPLATE.md`
2. **Location**: `Docs/05_Changes/Change-NNN-description.md`
3. **Must Include**:
   - Summary
   - Motivation
   - Files Changed (with line numbers)
   - Verification Steps
   - Rollback Notes

#### ADR (Required for major decisions)
1. **Template**: `Templates/ADR_TEMPLATE.md`
2. **Location**: `Docs/03_Decisions/ADR-NNN-title.md`
3. **When**: Architecture decisions, tech choices, design pattern selection
4. **Must Include**:
   - Status
   - Context
   - Decision
   - Consequences
   - Alternatives Considered

---

## 🎓 Learning Paths

### Path 1: Quick Start (30 minutes)
1. `README.md`
2. `Rules/AI_RULES.md`
3. `Skills/product-northstar/SKILL.md`
4. `Skills/database-schema/SKILL.md`
5. `THREADING_FIX_FINAL.md`

### Path 2: Full Onboarding (2-3 hours)
Follow `ONBOARDING_GUIDE.md` complete reading path

### Path 3: Feature Development (1 hour per feature)
1. Find Skill in `Skills/SKILLS_INDEX.md`
2. Read complete Skill specification
3. Review related ADRs
4. Check recent Changes for related work
5. Read relevant code files

### Path 4: Debugging & Troubleshooting (20 minutes)
1. `Skills/devtools-debug-suite/SKILL.md`
2. `Skills/privacy-redaction-standard/SKILL.md`
3. Recent Change logs for similar issues
4. Check console logs in DevTools

---

## ⚠️ Critical Information

### Known Issues (Fixed, Awaiting Test)
- ✅ **UI Freeze on Detail View** - Fixed in `THREADING_FIX_FINAL.md`
- ✅ **Privacy Leaks** - Fixed in `COMPLIANCE_FIX_SUMMARY.md`

### Placeholder Features (UI exists, logic incomplete)
See `Docs/01_Product/Placeholder_Features.md` for:
- Voice transcription (partial)
- Assist archive cards (partial)
- Some review pages (partial)

### Immediate TODO (P0)
1. Test latest fixes (UI freeze, privacy)
2. Complete manual testing checklist
3. Verify privacy redaction in production

### Short-term TODO (P1)
1. Implement "View Source" feature (data ready, UI needed)
2. Add unit tests (AIDebugRedactor, AtomTagStore)
3. Complete voice transcription
4. Add Chinese examples to AI prompts

---

## 📞 Support & Contact

### Getting Help
1. Check this index for relevant documentation
2. Search `Docs/04_Sessions/` for similar cases
3. Review related Skill documentation
4. Check ADRs for architectural context
5. Contact project team

### Reporting Issues
1. Create Session Log documenting the issue
2. Reference related Skills and ADRs
3. Include reproduction steps
4. Attach console logs from DevTools

### Contributing
1. Follow `Rules/WORKFLOW.md`
2. Strictly implement according to Skills
3. Create complete documentation (Session + Change logs)
4. Pass code review (`Rules/REVIEW_CHECKLIST.md`)
5. Submit with tests

---

## 🔗 Quick Links

### Most Important Documents
- [AI Rules](Rules/AI_RULES.md) - **Must read first**
- [Dev Log Rules](Rules/DEV_LOG_RULES.md) - **Documentation standards**
- [Product Northstar](Skills/product-northstar/SKILL.md) - **What we're building**
- [Database Schema](Skills/database-schema/SKILL.md) - **Data model**
- [AI Interaction](Skills/ai-interaction/SKILL.md) - **AI architecture**

### Latest Work
- [Threading Fix](THREADING_FIX_FINAL.md) - UI freeze solution
- [Compliance Fix](COMPLIANCE_FIX_SUMMARY.md) - Privacy protection
- [Latest Session](Docs/04_Sessions/2026-03-06_session-001.md) - Recent work

### Getting Started
- [Quick Start Guide](快速入门指南.md) - 10-minute intro (Chinese)
- [Complete Onboarding](ONBOARDING_GUIDE.md) - Full guide (Chinese)
- [Workflow](Rules/WORKFLOW.md) - Development process

---

## 📝 Version History

- **v1.0** (2026-03-06) - Initial comprehensive index

---

**Welcome to Life Narrator! Happy coding!** 🚀
