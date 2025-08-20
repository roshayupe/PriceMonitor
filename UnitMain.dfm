object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'Price Monitor'
  ClientHeight = 426
  ClientWidth = 579
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object cbCompetitors: TcxCheckComboBox
    Left = 40
    Top = 16
    Properties.EmptySelectionText = #1050#1086#1085#1082#1091#1088#1077#1085#1090#1080
    Properties.Items = <
      item
      end
      item
      end
      item
      end>
    TabOrder = 0
    Width = 329
  end
  object deDate: TcxDateEdit
    Left = 400
    Top = 17
    TabOrder = 1
    Width = 121
  end
  object cxButtonLoad: TcxButton
    Left = 97
    Top = 393
    Width = 100
    Height = 25
    Caption = #1047#1072#1074#1072#1085#1090#1072#1078#1080#1090#1080
    TabOrder = 2
    OnClick = cxButtonLoadClick
  end
  object cxButtonSave: TcxButton
    Left = 203
    Top = 393
    Width = 100
    Height = 25
    Caption = #1047#1073#1077#1088#1077#1075#1090#1080
    TabOrder = 3
    OnClick = cxButtonSaveClick
  end
  object cxButtonCancel: TcxButton
    Left = 309
    Top = 393
    Width = 100
    Height = 25
    Caption = #1057#1082#1072#1089#1091#1074#1072#1090#1080
    TabOrder = 4
    OnClick = cxButtonCancelClick
  end
  object cxGridMonitoring: TcxGrid
    Left = 41
    Top = 62
    Width = 480
    Height = 313
    TabOrder = 5
    object viewDB: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      DataController.DataSource = dsUI
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      Styles.OnGetContentStyle = viewDBStylesGetContentStyle
      object viewDBColumn1: TcxGridDBColumn
        DataBinding.IsNullValueType = True
      end
      object viewDBColumn2: TcxGridDBColumn
        DataBinding.IsNullValueType = True
      end
    end
    object cxGridMonitoringLevel: TcxGridLevel
      GridView = viewDB
    end
  end
  object OraSession: TOraSession
    Username = 'ADMIN'
    Server = 'monitor_high'
    Connected = True
    LoginPrompt = False
    Left = 65
    Top = 96
    EncryptedPassword = '98FF98FFAFFFCAFFBAFFCCFF95FF87FFCCFFB4FFBCFFCCFF'
  end
  object MemData: TdxMemData
    Active = True
    Indexes = <>
    SortOptions = []
    Left = 168
    Top = 160
  end
  object dsUI: TDataSource
    DataSet = MemData
    Left = 168
    Top = 240
  end
  object spGet: TOraStoredProc
    StoredProcName = 'TPERSON.GETCLASS'
    Session = OraSession
    SQL.Strings = (
      'begin'
      '  :RESULT := TPERSON.GETCLASS;'
      'end;')
    Options.DynamicReadThreshold = 0
    Left = 288
    Top = 160
    ParamData = <
      item
        DataType = ftString
        Name = 'RESULT'
        ParamType = ptResult
        Value = nil
        IsResult = True
      end>
    CommandStoredProcName = 'TPERSON.GETCLASS'
  end
  object spSave: TOraStoredProc
    StoredProcName = 'PRICE_MONITORING.SAVE_PRICES'
    Session = OraSession
    SQL.Strings = (
      'begin'
      '  PRICE_MONITORING.SAVE_PRICES(:P_DATA_CSV);'
      'end;')
    Options.DynamicReadThreshold = 0
    Left = 336
    Top = 160
    ParamData = <
      item
        DataType = ftString
        Name = 'P_DATA_CSV'
        ParamType = ptInput
        Value = nil
      end>
    CommandStoredProcName = 'PRICE_MONITORING.SAVE_PRICES'
  end
  object spGetPrev: TOraStoredProc
    StoredProcName = 'TPERSON.GETCLASS'
    Session = OraSession
    SQL.Strings = (
      'begin'
      '  :RESULT := TPERSON.GETCLASS;'
      'end;')
    Options.DynamicReadThreshold = 0
    Left = 288
    Top = 224
    ParamData = <
      item
        DataType = ftString
        Name = 'RESULT'
        ParamType = ptResult
        Value = nil
        IsResult = True
      end>
    CommandStoredProcName = 'TPERSON.GETCLASS'
  end
end
