import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:seddit/models/Community.dart";
import "package:seddit/pages/CommunityPage.dart";
import "package:seddit/providers/CommunityProvider.dart";

class CommunitiesPage extends StatelessWidget {
  const CommunitiesPage({super.key});

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Community Explorer"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const CreateCommunityDialog(),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text("Explore", style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 8),
            Text("Find and explore new communities to hang out, chat, and have fun with!", style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            Expanded(
              child: Consumer<CommunityProvider>(
                builder: (context, provider, child) {
                  return FutureBuilder<List<Community>>(
                    future: provider.communities,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text("No communities found"));
                      } else {
                        return GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final community = snapshot.data![index];
                            return CommunityChip(label: "s/${community.name}", name: community.name);
                          },
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;

  const CategoryChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}

class CommunityChip extends StatelessWidget {
  final String label;
  
  var name;

  CommunityChip({super.key, required this.label, required this.name});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("Navigating to community $name");
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => CommunityPage(communityName: name,),
        ));
      },
      child: Chip(
      label: Text(label),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ));
  }
}

class CreateCommunityDialog extends StatefulWidget {
  const CreateCommunityDialog({super.key});

  @override
  _CreateCommunityDialogState createState() => _CreateCommunityDialogState();
}

class _CreateCommunityDialogState extends State<CreateCommunityDialog> {
  final _formKey = GlobalKey<FormState>();
  String _name = "";
  String _description = "";
  String _category = "";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create New Community"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a name";
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Description"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a description";
                  }
                  return null;
                },
                onSaved: (value) => _description = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Category"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a category";
                  }
                  return null;
                },
                onSaved: (value) => _category = value!,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              Provider.of<CommunityProvider>(context, listen: false).createCommunity(
                _name,
                _description,
                _category,
                [], // Initial members list
                [], // Initial admins list
              ).then((_) {
                Navigator.of(context).pop();
              });
            }
          },
          child: const Text("Create"),
        ),
      ],
    );
  }
}
