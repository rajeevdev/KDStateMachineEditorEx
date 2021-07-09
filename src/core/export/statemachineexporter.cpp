/*
  This file is part of the KDAB State Machine Editor Library.

  SPDX-FileCopyrightText: 2015-2021 Klarälvdalens Datakonsult AB, a KDAB Group company <info@kdab.com>
  Author: Volker Krause <volker.krause@kdab.com>

  SPDX-License-Identifier: LGPL-2.1-only OR LicenseRef-KDAB-KDStateMachineEditor

  Licensees holding valid commercial KDAB State Machine Editor Library
  licenses may use this file in accordance with the KDAB State Machine Editor
  Library License Agreement provided with the Software.

  Contact info@kdab.com if any conditions of this licensing are not clear to you.
*/

#include "statemachineexporter.h"

#include "elementutil.h"
#include "objecthelper.h"
#include "state.h"
#include "transition.h"

#include <QDebug>
#include <QFontMetricsF>
#include <QGuiApplication>
#include <QPainterPath>
#include <QRectF>
#include <QTransform>
#include <QXmlStreamWriter>

using namespace KDSME;

namespace KDSME {

class StateMachineExporterPrivate
{
public:
    StateMachineExporterPrivate(QIODevice* device, StateMachineExporter* q);

    void init();

    bool writeStateMachine(StateMachine* machine);
    bool writeState(State* state);
    bool writeStateInner(State* state);
    bool writeTransition(Transition* transition);

    StateMachineExporter* q;
    QXmlStreamWriter m_writer;
};

StateMachineExporterPrivate::StateMachineExporterPrivate(QIODevice* device, StateMachineExporter* q)
    : q(q)
    , m_writer(device)
{
    init();
}

void StateMachineExporterPrivate::init()
{
    m_writer.setAutoFormatting(true);
}

bool StateMachineExporterPrivate::writeStateMachine(StateMachine* machine)
{
    Q_ASSERT(machine);


    // TODO: Check if preconditions are met, e.g. that all state labels are unique?

    m_writer.writeStartDocument();
    m_writer.writeStartElement("scxml");
    m_writer.writeDefaultNamespace("http://www.w3.org/2005/07/scxml");
    m_writer.writeAttribute("version", "1.0");
    if (!writeStateInner(machine))
        return false;
    m_writer.writeEndElement();
    m_writer.writeEndDocument();
    return !m_writer.hasError();
}

bool StateMachineExporterPrivate::writeState(State* state)
{
    if (qobject_cast<PseudoState*>(state)) {
        return true; // pseudo states are ignored
    }

    m_writer.writeStartElement("state");
    if (!writeStateInner(state))
        return false;
    m_writer.writeEndElement();
    return true;
}

bool StateMachineExporterPrivate::writeStateInner(State* state)
{
    if (state->label().isEmpty()) {
        q->setErrorString(QString("Encountered empty label for state: %1").arg(ObjectHelper::displayString(state)));
        return false;
    }

    if (qobject_cast<StateMachine*>(state)) {
        m_writer.writeAttribute("name", state->label());
        m_writer.writeAttribute("x", QString::number(state->pos().x()));
        m_writer.writeAttribute("y", QString::number(state->pos().y()));
        m_writer.writeAttribute("width", QString::number(state->width()));
        m_writer.writeAttribute("height", QString::number(state->height()));
    } else {
        m_writer.writeAttribute("id", state->label());
        m_writer.writeAttribute("x", QString::number(state->pos().x()));
        m_writer.writeAttribute("y", QString::number(state->pos().y()));
        m_writer.writeAttribute("width", QString::number(state->width()));
        m_writer.writeAttribute("height", QString::number(state->height()));
    }

    if (State* initial = ElementUtil::findInitialState(state)) {
        if (initial->label().isEmpty()) {
            q->setErrorString(QString("Encountered empty label for state: %1").arg(ObjectHelper::displayString(initial)));
            return false;
        }
        m_writer.writeAttribute("initial", initial->label());
    }

    foreach (Transition* transition, state->transitions()) {
        if (!writeTransition(transition))
            return false;
    }

    foreach (State* child, state->childStates()) {
        if (!writeState(child))
            return false;
    }
    return true;
}

bool StateMachineExporterPrivate::writeTransition(Transition* transition)
{
    m_writer.writeStartElement("transition");
    m_writer.writeAttribute("event", transition->label());
    if (State* targetState = transition->targetState()) {
        m_writer.writeAttribute("target", targetState->label());
    }
    m_writer.writeEndElement();
    return true;
}


StateMachineExporter::StateMachineExporter(QIODevice* device)
    : d(new StateMachineExporterPrivate(device, this))
{
}

StateMachineExporter::~StateMachineExporter()
{
}

bool StateMachineExporter::exportMachine(StateMachine* machine)
{
    setErrorString(QString());

    if (!machine) {
        setErrorString("Null machine instance passed");
        return false;
    }

    if (d->m_writer.hasError()) {
        setErrorString("Setting up XML writer failed");
        return false;
    }

    return d->writeStateMachine(machine);
}
}
