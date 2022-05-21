import 'package:flutter/material.dart';
import 'package:image_store/models/image_item.dart';
import 'package:image_store/view_models/home_view_model.dart';
import 'package:image_store/widgets/image_item.dart';
import 'package:image_store/widgets/image_viewer.dart';
import 'package:image_store/widgets/loader.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    Provider.of<HomeViewModel>(context, listen: false).fetchImages();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, model, _) {
        return LoaderPage(
          busy: model.isSecondaryBusy,
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Image Firestore"),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => showImageSelectionBottomSheet(
                context,
                onCamera: model.fromCamera,
                onUpload: model.fromGalley,
              ),
              icon: const Icon(
                Icons.camera_alt,
                size: 28,
                color: Colors.white,
              ),
              label: const Text(
                r'Add Image',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: ThemeData().primaryColor,
            ),
            body: model.isBusy
                //when fetching items
                ? const Center(child: CircularProgressIndicator())
                : //after fetching items
                Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 10,
                    ),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1,
                      ),
                      itemCount: model.items.length,
                      itemBuilder: (context, index) {
                        ImageItem item = model.items[index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ImageViewerWrapper(
                                    titleGallery: item.author,
                                    galleryItems: model.items,
                                    backgroundDecoration: const BoxDecoration(
                                      color: Colors.black,
                                    ),
                                    initialIndex: index,
                                    scrollDirection: Axis.horizontal,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.5),
                                  width: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: ImageItemWidget(
                                item: item,
                                onDelete: () => model.delete(item),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        );
      },
    );
  }

// bottom sheet for image seletion
  showImageSelectionBottomSheet(context,
      {Function()? onCamera, Function()? onUpload}) {
    // showBottomSheet(context)
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      // clipBehavior: Clip,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 280,
          child: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                const Text("Select a way to add images"),
                const SizedBox(height: 20),
                ListTile(
                  onTap: () {
                    if (onCamera != null) {
                      Navigator.pop(context);
                      onCamera();
                    }
                  },
                  title: const Text("Take a photo"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
                const Divider(),
                ListTile(
                  onTap: () {
                    if (onUpload != null) {
                      Navigator.pop(context);
                      onUpload();
                    }
                  },
                  title: const Text("Upload from device"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
