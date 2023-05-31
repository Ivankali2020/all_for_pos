import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:pos/Models/Category.dart';
import 'package:pos/Models/TransitionPage.dart';
import 'package:pos/Providers/CategoryProvider.dart';
import '../Providers/ProductProvider.dart';
import 'package:provider/provider.dart';

class CategoryWidget extends StatelessWidget {
  const CategoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    void deleteProduct(int id, Category category) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(category.name),
          content:
              const Text('You can not be restore this items! Are you Sure?'),
          actions: [
            ElevatedButton.icon(
                onPressed: () {
                  Provider.of<CategoryProvider>(context, listen: false)
                      .deleteCategory(id, category);
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.delete),
                label: const Text('Delete'))
          ],
        ),
      );
    }

    final TextEditingController editName = TextEditingController();
    final GlobalKey<FormState> editKey = GlobalKey<FormState>();

    void editSubmitForm(int id) {
      if (!editKey.currentState!.validate()) {
        return;
      }

      Provider.of<CategoryProvider>(context, listen: false)
          .updateCategory(id, editName.text)
          .then((value) {
        editName.clear();
        Navigator.of(context).pop();
      });
    }

    Future editCategoryBox(String name, int id) {
      editName.text = name;
      return showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: const Text('Edit Category'),
              content: SizedBox(
                height: 150,
                child: Form(
                  key: editKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: 'Category Name',
                          border: OutlineInputBorder(gapPadding: 0),
                        ),
                        controller: editName,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          null;
                        },
                      ),
                      ElevatedButton(
                        onPressed: () => editSubmitForm(id),
                        child: const Text('Save'),
                      )
                    ],
                  ),
                ),
              ),
            );
          });
    }

    return Consumer<CategoryProvider>(
      // child: const Center(child: Text('No Place Found')),
      builder: (context, value, child) => value.categories.length > 0
          ? ListView.builder(
              itemCount: value.categories.length,
              itemBuilder: (ctx, i) => Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(8)),
                child: ListTile(
                  title: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                    child: Text(value.categories[i].name),
                  ),
                  trailing: Container(
                    width: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          onPressed: () => editCategoryBox(
                              value.categories[i].name, value.categories[i].id),
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () => deleteProduct(
                              value.categories[i].id, value.categories[i]),
                          icon: const Icon(Icons.delete_forever),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : const Center(
              child: Text('No Categoires Found'),
            ),
    );
  }
}
