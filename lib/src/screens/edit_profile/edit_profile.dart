import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hr_platform/src/models/user_model.dart';
import 'package:hr_platform/src/theme/text_field_input_decoration.dart';

import '../add_user/add_user.dart';

class EditProfile extends StatefulWidget {
  final UserModel userModel;
  final Map<String, dynamic>? extraDataTOSave;
  const EditProfile({super.key, required this.userModel, this.extraDataTOSave});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController passwordController;
  late TextEditingController userNameController;
  late TextEditingController cellPhoneController;
  late TextEditingController companyNameController;
  late TextEditingController dateOfJoiningController;
  late TextEditingController departmentNameController;
  late TextEditingController designationNameController;
  late TextEditingController emailController;
  late TextEditingController jobTypeNameController;
  Map<String, dynamic>? extraDataTOSave;

  FocusNode userNameFocusNode = FocusNode();
  FocusNode cellPhoneFocusNode = FocusNode();
  FocusNode companyNameFocusNode = FocusNode();
  FocusNode dateOfJoiningFocusNode = FocusNode();
  FocusNode departmentNameFocusNode = FocusNode();
  FocusNode designationNameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode jobTypeNameFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();

  @override
  void initState() {
    passwordController =
        TextEditingController(text: widget.userModel.userPassword);
    userNameController = TextEditingController(text: widget.userModel.userName);
    cellPhoneController =
        TextEditingController(text: widget.userModel.cellPhone);
    companyNameController =
        TextEditingController(text: widget.userModel.companyName);
    dateOfJoiningController =
        TextEditingController(text: widget.userModel.dateOfJoining);
    departmentNameController =
        TextEditingController(text: widget.userModel.departmentName);
    designationNameController =
        TextEditingController(text: widget.userModel.designationName);
    emailController = TextEditingController(text: widget.userModel.email);
    jobTypeNameController =
        TextEditingController(text: widget.userModel.jobTypeName);
    extraDataTOSave = widget.extraDataTOSave;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit user info"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  titleWidget("User Password", true),
                  const Gap(5),
                  TextFormField(
                    onFieldSubmitted: (value) {
                      userNameFocusNode.requestFocus();
                    },
                    focusNode: passwordFocusNode,
                    validator: (value) {
                      if (value == null || value.length < 3) {
                        return "Password should be at least 4 digit";
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: passwordController,
                    decoration: getInputDecooration(
                      "User Password",
                      "Type password for new user...",
                    ),
                  ),
                  titleWidget("User Name", false),
                  const Gap(5),
                  TextFormField(
                    onFieldSubmitted: (value) {
                      cellPhoneFocusNode.requestFocus();
                    },
                    focusNode: userNameFocusNode,
                    controller: userNameController,
                    decoration: getInputDecooration(
                      "User Name",
                      "Type user name for new user...",
                    ),
                  ),
                  const Gap(10),
                  titleWidget("Cell Phone", false),
                  const Gap(5),
                  TextFormField(
                    onFieldSubmitted: (value) {
                      companyNameFocusNode.requestFocus();
                    },
                    focusNode: cellPhoneFocusNode,
                    controller: cellPhoneController,
                    decoration: getInputDecooration(
                      "Cell Phone",
                      "Type user Cell Phone...",
                    ),
                  ),
                  const Gap(10),
                  titleWidget("Company Name", false),
                  const Gap(5),
                  TextFormField(
                    onFieldSubmitted: (value) {
                      dateOfJoiningFocusNode.requestFocus();
                    },
                    focusNode: companyNameFocusNode,
                    controller: companyNameController,
                    decoration: getInputDecooration(
                      "Company Name",
                      "Type Company Name of new user...",
                    ),
                  ),
                  const Gap(10),
                  titleWidget("Date Of Joining", false),
                  const Gap(5),
                  TextFormField(
                    onFieldSubmitted: (value) {
                      departmentNameFocusNode.requestFocus();
                    },
                    focusNode: dateOfJoiningFocusNode,
                    controller: dateOfJoiningController,
                    decoration: getInputDecooration(
                      "Date Of Joining",
                      "Type Date Of Joining of new user...",
                    ),
                  ),
                  const Gap(10),
                  titleWidget("Department Name", false),
                  const Gap(5),
                  TextFormField(
                    onFieldSubmitted: (value) {
                      designationNameFocusNode.requestFocus();
                    },
                    focusNode: departmentNameFocusNode,
                    controller: departmentNameController,
                    decoration: getInputDecooration(
                      "Department Name",
                      "Type Department Name of new user...",
                    ),
                  ),
                  const Gap(10),
                  titleWidget("Designation Name", false),
                  const Gap(5),
                  TextFormField(
                    onFieldSubmitted: (value) {
                      emailFocusNode.requestFocus();
                    },
                    focusNode: designationNameFocusNode,
                    controller: designationNameController,
                    decoration: getInputDecooration(
                      "Designation Name",
                      "Type Designation Name of new user...",
                    ),
                  ),
                  const Gap(10),
                  titleWidget("Email", false),
                  const Gap(5),
                  TextFormField(
                    onFieldSubmitted: (value) {
                      jobTypeNameFocusNode.requestFocus();
                    },
                    focusNode: emailFocusNode,
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: getInputDecooration(
                      "Email",
                      "Type Email of new user...",
                    ),
                  ),
                  const Gap(10),
                  titleWidget("Job Type Name", false),
                  const Gap(5),
                  TextFormField(
                    onFieldSubmitted: (value) async {
                      await onSaveChangesButtonPressed(context);
                    },
                    focusNode: jobTypeNameFocusNode,
                    controller: jobTypeNameController,
                    decoration: getInputDecooration(
                      "Job Type",
                      "Type Job Type Name of new user...",
                    ),
                  ),
                  const Gap(20),
                  SizedBox(
                    width: 330,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await onSaveChangesButtonPressed(context);
                      },
                      label: const Text("Save Changes"),
                      icon: const Icon(Icons.done),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> onSaveChangesButtonPressed(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      try {
        UserModel model = UserModel(
          userID: widget.userModel.userID,
          userPassword: passwordController.text,
          userName: userNameController.text,
          cellPhone: cellPhoneController.text,
          companyName: companyNameController.text,
          dateOfJoining: dateOfJoiningController.text,
          departmentName: departmentNameController.text,
          designationName: designationNameController.text,
          email: emailController.text,
          jobTypeName: jobTypeNameController.text,
        );
        await FirebaseFirestore.instance
            .collection("general_user")
            .doc(widget.userModel.userID)
            .update(model.toMap());
        if (extraDataTOSave != null) {
          extraDataTOSave!.addAll(Map<String, dynamic>.from(
              {widget.userModel.userID!: model.toMap()}));

          final box = await Hive.openBox("allUserCached");
          await box.put("data", extraDataTOSave);
        }
        Navigator.pushNamedAndRemoveUntil(
          // ignore: use_build_context_synchronously
          context,
          "/",
          (route) => false,
        );
      } catch (e) {
        showModalBottomSheet(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) => const Center(
            child: Text("Somethings went worng"),
          ),
        );
      }
    }
  }
}
