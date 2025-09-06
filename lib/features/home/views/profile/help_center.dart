import 'package:flutter/material.dart';
import 'package:story_map/features/home/views/profile/feedback_page.dart';
import 'package:story_map/features/home/views/profile/report_issue.dart';
import 'package:story_map/l10n/app_localizations.dart';

class HelpCenter extends StatefulWidget {
  const HelpCenter({super.key});

  @override
  State<HelpCenter> createState() => _HelpCenterState();
}

class _HelpCenterState extends State<HelpCenter> {
  @override
  Widget build(BuildContext context) {
    // AppLocalizations kullanmak için build içinde oluşturduk
    final List<Map<String, String>> helpTopics = [
      {
        "title": AppLocalizations.of(context)!.help_editAccount_title,
        "content": AppLocalizations.of(context)!.help_editAccount_content,
      },
      {
        "title": AppLocalizations.of(context)!.help_shareRoute_title,
        "content": AppLocalizations.of(context)!.help_shareRoute_content,
      },
      {
        "title": AppLocalizations.of(context)!.help_favorites_title,
        "content": AppLocalizations.of(context)!.help_favorites_content,
      },
      {
        "title": AppLocalizations.of(context)!.help_editLocation_title,
        "content": AppLocalizations.of(context)!.help_editLocation_content,
      },
      {
        "title": AppLocalizations.of(context)!.help_reportIssue_title,
        "content": AppLocalizations.of(context)!.help_reportIssue_content,
      },
      {
        "title": AppLocalizations.of(context)!.help_deleteRoute_title,
        "content": AppLocalizations.of(context)!.help_deleteRoute_content,
      },
      {
        "title": AppLocalizations.of(context)!.help_addFavorites_title,
        "content": AppLocalizations.of(context)!.help_addFavorites_content,
      },
      {
        "title": AppLocalizations.of(context)!.help_addComment_title,
        "content": AppLocalizations.of(context)!.help_addComment_content,
      },
      {
        "title": AppLocalizations.of(context)!.help_changeLanguage_title,
        "content": AppLocalizations.of(context)!.help_changeLanguage_content,
      },
      {
        "title": AppLocalizations.of(context)!.help_notifications_title,
        "content": AppLocalizations.of(context)!.help_notifications_content,
      },
      {
        "title": AppLocalizations.of(context)!.help_viewStories_title,
        "content": AppLocalizations.of(context)!.help_viewStories_content,
      },
      {
        "title": AppLocalizations.of(context)!.help_offlineUsage_title,
        "content": AppLocalizations.of(context)!.help_offlineUsage_content,
      },
      {
        "title": AppLocalizations.of(context)!.help_deleteAccount_title,
        "content": AppLocalizations.of(context)!.help_deleteAccount_content,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(AppLocalizations.of(context)!.helpCenterTitle,
            style: const TextStyle(color: Colors.black)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: helpTopics.length,
              itemBuilder: (context, index) {
                final topic = helpTopics[index];
                return ExpansionTile(
                  title: Text(topic["title"] ?? ""),
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        topic["content"] ?? "",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.feedback_outlined, color: Colors.black),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FeedbackPage()),
                      );
                    },
                    label: Text(AppLocalizations.of(context)!.sendFeedback,
                        style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.report_problem_outlined,
                        color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ReportIssuePage()),
                      );
                    },
                    label: Text(AppLocalizations.of(context)!.reportIssue,
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
