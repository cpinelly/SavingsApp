import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:savings_app/blocs/authentication/authentication_bloc.dart';
import 'package:savings_app/blocs/authentication/authentication_events.dart';
import 'package:savings_app/blocs/settings_syncer/settings_syncer_bloc.dart';
import 'package:savings_app/blocs/settings_syncer/settings_syncer_states.dart';
import 'package:savings_app/blocs/settings_syncer/settings_syncer_events.dart';
import 'package:savings_app/repositories/accounts_repository.dart';
import 'package:savings_app/repositories/funds_repository.dart';
import 'package:savings_app/repositories/transactions_repository.dart';
import 'package:savings_app/screens/new_transaction_screen.dart';
import 'package:savings_app/widgets/in_out_form.dart';
import 'package:savings_app/widgets/my_summary.dart';

class HomeScreen extends StatefulWidget {
  String authToken;

  HomeScreen({@required this.authToken});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _selectedPageIndex = 1;

  Widget _body() {
    // TODO: Move to initialState

    var fundsRepository = FundsRepository(authToken: widget.authToken);
    var accountsRepository = AccountsRepository(authToken: widget.authToken);

    var transactionsRepository =
        TransactionsRepository(authToken: widget.authToken, fundsRepository: fundsRepository);



    var bloc = SettingsSyncerBloc(
        accountsRepository: accountsRepository,
        fundsRepository: fundsRepository);

    return BlocProvider(
      create: (context) {
        return bloc;
      },
      child: BlocBuilder<SettingsSyncerBloc, SettingsSyncState>(
          builder: (context, state) {
        // TODO: Improvable
        if (state is SyncInitial)
          BlocProvider.of<SettingsSyncerBloc>(context)
              .add(SettingsSyncerUpdateRequested());

        if (state is SettingsUpdated ||
            (state is SyncingSettings && !state.initial)) {
          var bloc = BlocProvider.of<SettingsSyncerBloc>(context);
          return IndexedStack(
            index: _selectedPageIndex,
            children: [
              MySummary(
                  token: widget.authToken,
                  fundsRepository: bloc.fundsRepository,
                  accountsRepository: bloc.accountsRepository,
                  transactionsRepository: transactionsRepository),
              InOutForm(
                funds: bloc.fundsRepository.funds,
                accounts: bloc.accountsRepository.accounts,
                transactionsRepository: transactionsRepository,
              ),
              Container(
                child: Center(
                  child: Text("Settings"),
                ),
              )
            ],
          );
        }

        return Container(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  CircularProgressIndicator(),
                  Text("Syncing")
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  void _onTabSelected(int pageIndex) {
    setState(() {
      _selectedPageIndex = pageIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              BlocProvider.of<AuthenticationBloc>(context)
                  .add(AuthenticationLoggedOut());
            },
          )
        ],
      ),
      body: _body(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedPageIndex,
        onTap: _onTabSelected,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), title: Text("Dashboard")),
          BottomNavigationBarItem(
              icon: Icon(Icons.add), title: Text("New Transaction")),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), title: Text("Settings"))
        ],
      ),
    );
  }
}
